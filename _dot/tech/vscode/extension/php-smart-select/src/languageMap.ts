/**
 * Maps VS Code language IDs to Tree-sitter grammar names and .wasm file names.
 */

export interface LanguageEntry {
  /** Tree-sitter grammar name (used for display/logging) */
  grammarName: string;
  /** Name of the .wasm file (without path) */
  wasmFile: string;
}

/**
 * Mapping from VS Code `document.languageId` to Tree-sitter grammar info.
 */
const LANGUAGE_MAP: ReadonlyMap<string, LanguageEntry> = new Map([
  ["typescript", { grammarName: "typescript", wasmFile: "tree-sitter-typescript.wasm" }],
  ["typescriptreact", { grammarName: "tsx", wasmFile: "tree-sitter-tsx.wasm" }],
  ["javascript", { grammarName: "javascript", wasmFile: "tree-sitter-javascript.wasm" }],
  ["javascriptreact", { grammarName: "javascript", wasmFile: "tree-sitter-javascript.wasm" }],
  ["python", { grammarName: "python", wasmFile: "tree-sitter-python.wasm" }],
  ["rust", { grammarName: "rust", wasmFile: "tree-sitter-rust.wasm" }],
  ["go", { grammarName: "go", wasmFile: "tree-sitter-go.wasm" }],
  ["c", { grammarName: "c", wasmFile: "tree-sitter-c.wasm" }],
  ["cpp", { grammarName: "cpp", wasmFile: "tree-sitter-cpp.wasm" }],
  ["java", { grammarName: "java", wasmFile: "tree-sitter-java.wasm" }],
  ["ruby", { grammarName: "ruby", wasmFile: "tree-sitter-ruby.wasm" }],
  ["html", { grammarName: "html", wasmFile: "tree-sitter-html.wasm" }],
  ["css", { grammarName: "css", wasmFile: "tree-sitter-css.wasm" }],
  ["json", { grammarName: "json", wasmFile: "tree-sitter-json.wasm" }],
  ["shellscript", { grammarName: "bash", wasmFile: "tree-sitter-bash.wasm" }],
  ["php", { grammarName: "php", wasmFile: "tree-sitter-php.wasm" }],
]);

/**
 * Get the Tree-sitter language entry for a given VS Code language ID.
 * Returns undefined if the language is not supported.
 */
export function getLanguageEntry(languageId: string): LanguageEntry | undefined {
  return LANGUAGE_MAP.get(languageId);
}

/**
 * Get all supported VS Code language IDs.
 */
export function getSupportedLanguageIds(): string[] {
  return [...LANGUAGE_MAP.keys()];
}

/**
 * Check if a language ID is supported by the built-in mappings.
 */
export function isLanguageSupported(languageId: string): boolean {
  return LANGUAGE_MAP.has(languageId);
}
