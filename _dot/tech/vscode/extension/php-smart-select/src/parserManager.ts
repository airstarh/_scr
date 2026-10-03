import * as path from "path";
import * as vscode from "vscode";
import { Parser, Language, Tree } from "web-tree-sitter";
import { getLanguageEntry } from "./languageMap";

/**
 * Manages Tree-sitter parser instances and language loading.
 * Handles initialization of the WASM runtime and lazy loading of language parsers.
 */
export class ParserManager {
  private parser: Parser | undefined;
  private loadedLanguages = new Map<string, Language>();
  private loadingLanguages = new Map<string, Promise<Language | undefined>>();
  private wasmDir: string;
  private customParsers: Record<string, string> = {};
  private initialized = false;
  private initPromise: Promise<void> | undefined;

  constructor(private readonly extensionUri: vscode.Uri) {
    this.wasmDir = path.join(extensionUri.fsPath, "dist", "wasm");
  }

  /**
   * Initialize the Tree-sitter WASM runtime. Must be called before parsing.
   * Safe to call multiple times — subsequent calls are no-ops.
   */
  async initialize(): Promise<void> {
    if (this.initialized) return;
    if (this.initPromise) return this.initPromise;

    this.initPromise = this.doInit();
    return this.initPromise;
  }

  private async doInit(): Promise<void> {
    try {
      const wasmPath = path.join(this.wasmDir, "tree-sitter.wasm");
      await Parser.init({
        locateFile: () => wasmPath,
      });
      this.parser = new Parser();
      this.initialized = true;

      // Load custom parser paths from configuration
      this.refreshCustomParsers();
    } catch (err) {
      console.error("[tree-sitter-smart-select] Failed to initialize Tree-sitter:", err);
      throw err;
    }
  }

  /**
   * Refresh the custom parser paths from user settings.
   */
  refreshCustomParsers(): void {
    const config = vscode.workspace.getConfiguration("treeSitterSmartSelect");
    this.customParsers = config.get<Record<string, string>>("additionalParsers", {});
  }

  /**
   * Get or lazily load the Tree-sitter Language for a VS Code languageId.
   * Returns undefined if the language is not supported or loading fails.
   */
  async getLanguage(languageId: string): Promise<Language | undefined> {
    // Check cache
    const cached = this.loadedLanguages.get(languageId);
    if (cached) return cached;

    // Check if already loading (dedup concurrent requests)
    const loading = this.loadingLanguages.get(languageId);
    if (loading) return loading;

    const promise = this.loadLanguage(languageId);
    this.loadingLanguages.set(languageId, promise);

    try {
      const lang = await promise;
      if (lang) {
        this.loadedLanguages.set(languageId, lang);
      }
      return lang;
    } finally {
      this.loadingLanguages.delete(languageId);
    }
  }

  private async loadLanguage(languageId: string): Promise<Language | undefined> {
    // Try custom parser path first
    const customPath = this.customParsers[languageId];
    if (customPath) {
      try {
        return await Language.load(customPath);
      } catch (err) {
        console.warn(
          `[tree-sitter-smart-select] Failed to load custom parser for "${languageId}" from ${customPath}:`,
          err
        );
      }
    }

    // Try built-in language map
    const entry = getLanguageEntry(languageId);
    if (!entry) return undefined;

    const wasmPath = path.join(this.wasmDir, entry.wasmFile);
    try {
      return await Language.load(wasmPath);
    } catch (err) {
      console.warn(
        `[tree-sitter-smart-select] Failed to load parser for "${languageId}" (${entry.wasmFile}):`,
        err
      );
      return undefined;
    }
  }

  /**
   * Parse the given source code with the parser set to the specified language.
   * Returns undefined if the language is not available.
   */
  async parse(
    source: string,
    languageId: string,
    oldTree?: Tree
  ): Promise<Tree | undefined> {
    if (!this.parser) return undefined;

    const lang = await this.getLanguage(languageId);
    if (!lang) return undefined;

    this.parser.setLanguage(lang);
    return this.parser.parse(source, oldTree) ?? undefined;
  }

  /**
   * Check if a language is potentially supported (has a mapping or custom path).
   */
  isLanguagePotentiallySupported(languageId: string): boolean {
    return (
      languageId in this.customParsers || getLanguageEntry(languageId) !== undefined
    );
  }

  /**
   * Dispose all parser resources (WASM memory).
   */
  dispose(): void {
    for (const lang of this.loadedLanguages.values()) {
      // Language objects don't have a delete method in web-tree-sitter,
      // but we clear the map to release references.
    }
    this.loadedLanguages.clear();
    this.loadingLanguages.clear();

    if (this.parser) {
      this.parser.delete();
      this.parser = undefined;
    }

    this.initialized = false;
    this.initPromise = undefined;
  }
}
