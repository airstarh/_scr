import * as vscode from "vscode";
import { Tree, Edit } from "web-tree-sitter";
import { ParserManager } from "./parserManager";

interface CachedTree {
  tree: Tree;
  version: number;
}

/**
 * Caches parsed Tree-sitter syntax trees per document.
 * Supports incremental updates on document changes and
 * automatic cleanup on document close.
 */
export class TreeCache {
  private cache = new Map<string, CachedTree>();
  private disposables: vscode.Disposable[] = [];

  constructor(private readonly parserManager: ParserManager) {}

  /**
   * Start listening for document changes and closures.
   */
  activate(): void {
    this.disposables.push(
      vscode.workspace.onDidChangeTextDocument((e) => this.onDocumentChange(e)),
      vscode.workspace.onDidCloseTextDocument((doc) => this.onDocumentClose(doc))
    );
  }

  /**
   * Get the parsed tree for a document, parsing or re-parsing as needed.
   * Returns undefined if the language is not supported or parsing fails.
   */
  async getTree(document: vscode.TextDocument): Promise<Tree | undefined> {
    const key = document.uri.toString();
    const cached = this.cache.get(key);

    // Return cached tree if version matches
    if (cached && cached.version === document.version) {
      return cached.tree;
    }

    // Parse (or re-parse) the full document
    const source = document.getText();
    const tree = await this.parserManager.parse(
      source,
      document.languageId,
      cached?.tree // pass old tree for incremental parsing if available
    ) ?? undefined;

    if (!tree) return undefined;

    // Delete old tree to free WASM memory
    if (cached?.tree) {
      cached.tree.delete();
    }

    this.cache.set(key, { tree, version: document.version });
    return tree;
  }

  /**
   * Handle document content changes. Applies Tree-sitter edit operations
   * to the cached tree so the next parse can be incremental.
   */
  private onDocumentChange(event: vscode.TextDocumentChangeEvent): void {
    const key = event.document.uri.toString();
    const cached = this.cache.get(key);
    if (!cached) return;

    for (const change of event.contentChanges) {
      const startIndex = event.document.offsetAt(change.range.start);
      const oldEndIndex = startIndex + change.rangeLength;
      const newEndIndex = startIndex + change.text.length;

      const startPosition = {
        row: change.range.start.line,
        column: change.range.start.character,
      };

      const oldEndPosition = {
        row: change.range.end.line,
        column: change.range.end.character,
      };

      // Calculate new end position
      const newLines = change.text.split("\n");
      const newEndRow =
        change.range.start.line + newLines.length - 1;
      const newEndColumn =
        newLines.length === 1
          ? change.range.start.character + newLines[0].length
          : newLines[newLines.length - 1].length;

      const newEndPosition = {
        row: newEndRow,
        column: newEndColumn,
      };

      cached.tree.edit(new Edit({
        startIndex,
        oldEndIndex,
        newEndIndex,
        startPosition,
        oldEndPosition,
        newEndPosition,
      }));
    }

    // Mark version as stale so getTree() will re-parse
    cached.version = -1;
  }

  /**
   * Clean up cached tree when a document is closed.
   */
  private onDocumentClose(document: vscode.TextDocument): void {
    const key = document.uri.toString();
    const cached = this.cache.get(key);
    if (cached) {
      cached.tree.delete();
      this.cache.delete(key);
    }
  }

  /**
   * Invalidate all cached trees (e.g., on configuration change).
   */
  invalidateAll(): void {
    for (const cached of this.cache.values()) {
      cached.tree.delete();
    }
    this.cache.clear();
  }

  /**
   * Dispose all resources.
   */
  dispose(): void {
    this.invalidateAll();
    for (const d of this.disposables) {
      d.dispose();
    }
    this.disposables = [];
  }
}
