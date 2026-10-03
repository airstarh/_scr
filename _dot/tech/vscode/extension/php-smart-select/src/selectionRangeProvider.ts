import * as vscode from "vscode";
import type { Tree, Node, Point } from "web-tree-sitter";
import { TreeCache } from "./treeCache";

/** Punctuation/delimiter node types that bracket inner content */
const BRACKET_TYPES = new Set(["(", ")", "{", "}", "[", "]", "<", ">", "«", "»"]);

/** String-like node types whose inner content (excluding quotes) should be an extra selection step */
const STRING_NODE_TYPES = new Set([
  "string",
  "string_literal",
  "template_string",
  "raw_string",
  "interpreted_string_literal",
  "string_content",
]);

/**
 * Provides AST-aware selection ranges using Tree-sitter.
 * Registered as a SelectionRangeProvider to enhance VS Code's
 * built-in Expand/Shrink Selection (⌃⇧⌘→/←).
 */
export class TreeSitterSelectionRangeProvider implements vscode.SelectionRangeProvider {
  constructor(
    private readonly treeCache: TreeCache,
    private readonly maxFileSize: number,
    private readonly includeAnonymousNodes: boolean
  ) {}

  async provideSelectionRanges(
    document: vscode.TextDocument,
    positions: vscode.Position[],
    _token: vscode.CancellationToken
  ): Promise<vscode.SelectionRange[]> {
    // Skip files that are too large
    if (document.getText().length > this.maxFileSize) {
      return [];
    }

    const tree = await this.treeCache.getTree(document);
    if (!tree) {
      return [];
    }

    return positions.map((pos) => this.buildSelectionChain(tree, document, pos));
  }

  /**
   * Build a linked list of SelectionRange from the smallest AST node at `position`
   * up to the root node, plus the full document range.
   */
  private buildSelectionChain(
    tree: Tree,
    document: vscode.TextDocument,
    position: vscode.Position
  ): vscode.SelectionRange {
    const tsPoint: Point = {
      row: position.line,
      column: position.character,
    };

    // Find the smallest (deepest) node at the cursor position
    let node: Node | null = tree.rootNode.descendantForPosition(tsPoint);

    // Collect all ancestor nodes from deepest to root
    const nodes: Node[] = [];
    while (node) {
      nodes.push(node);
      node = node.parent;
    }

    // Build the SelectionRange chain from outermost to innermost.
    // We iterate in reverse (root → leaf) so we can set parent references correctly.
    // Then filter and enhance the chain.
    const rangeEntries = this.buildRangeEntries(nodes, document);

    // Build linked list from outermost (last) to innermost (first)
    let parent: vscode.SelectionRange | undefined;
    for (let i = rangeEntries.length - 1; i >= 0; i--) {
      parent = new vscode.SelectionRange(rangeEntries[i], parent);
    }

    // If we got nothing, fall back to a single range at the cursor position
    if (!parent) {
      const cursorRange = new vscode.Range(position, position);
      parent = new vscode.SelectionRange(cursorRange);
    }

    return parent;
  }

  /**
   * Build an ordered list of ranges (innermost first) from the node ancestry.
   * Applies filtering and enhancement:
   * - Skips anonymous nodes (unless configured)
   * - Deduplicates identical ranges
   * - Adds inner-content ranges for bracketed and string nodes
   */
  private buildRangeEntries(
    nodes: Node[],
    document: vscode.TextDocument
  ): vscode.Range[] {
    const ranges: vscode.Range[] = [];
    let prevRange: vscode.Range | undefined;

    for (const node of nodes) {
      // Optionally skip anonymous (unnamed) nodes like punctuation
      if (!this.includeAnonymousNodes && !node.isNamed) {
        continue;
      }

      const range = this.nodeToRange(node);

      // Skip if this range is identical to the previous one (dedup)
      if (prevRange && this.rangesEqual(range, prevRange)) {
        continue;
      }

      // For string nodes, add inner content range (excluding quotes)
      if (this.isStringNode(node)) {
        const innerRange = this.getStringInnerRange(node, document);
        if (innerRange && (!prevRange || !this.rangesEqual(innerRange, prevRange))) {
          ranges.push(innerRange);
          prevRange = innerRange;
        }
      }

      // For bracket-like container nodes, add inner content range (between delimiters)
      if (node.childCount > 0) {
        const innerRange = this.getBracketInnerRange(node);
        if (innerRange && (!prevRange || !this.rangesEqual(innerRange, prevRange))) {
          if (!this.rangesEqual(innerRange, range)) {
            ranges.push(innerRange);
            prevRange = innerRange;
          }
        }
      }

      ranges.push(range);
      prevRange = range;
    }

    return ranges;
  }

  /**
   * Convert a Tree-sitter SyntaxNode to a VS Code Range.
   */
  private nodeToRange(node: Node): vscode.Range {
    return new vscode.Range(
      new vscode.Position(node.startPosition.row, node.startPosition.column),
      new vscode.Position(node.endPosition.row, node.endPosition.column)
    );
  }

  /**
   * Check if two ranges are exactly equal.
   */
  private rangesEqual(a: vscode.Range, b: vscode.Range): boolean {
    return a.start.isEqual(b.start) && a.end.isEqual(b.end);
  }

  /**
   * Check if a node represents a string literal.
   */
  private isStringNode(node: Node): boolean {
    return STRING_NODE_TYPES.has(node.type);
  }

  /**
   * Get the inner range of a string node (content without surrounding quotes).
   */
  private getStringInnerRange(
    node: Node,
    document: vscode.TextDocument
  ): vscode.Range | undefined {
    if (node.childCount > 0) {
      // Many Tree-sitter grammars have children for string content
      // Find the first and last content children (skip quote tokens)
      const children = [];
      for (let i = 0; i < node.childCount; i++) {
        const child = node.child(i);
        if (child && !this.isQuoteNode(child)) {
          children.push(child);
        }
      }
      if (children.length > 0) {
        const first = children[0];
        const last = children[children.length - 1];
        return new vscode.Range(
          new vscode.Position(first.startPosition.row, first.startPosition.column),
          new vscode.Position(last.endPosition.row, last.endPosition.column)
        );
      }
    }

    // Fallback: shrink by 1 character on each side (for simple "..." or '...' strings)
    const text = document.getText(this.nodeToRange(node));
    if (text.length >= 2) {
      const startOffset = document.offsetAt(
        new vscode.Position(node.startPosition.row, node.startPosition.column)
      );
      // Detect quote length (could be """ or ''' for triple-quoted strings)
      let quoteLen = 1;
      if (text.length >= 6 && text.startsWith('"""') || text.startsWith("'''") || text.startsWith("```")) {
        quoteLen = 3;
      }
      const innerStart = document.positionAt(startOffset + quoteLen);
      const innerEnd = document.positionAt(startOffset + text.length - quoteLen);
      if (innerStart.isBefore(innerEnd)) {
        return new vscode.Range(innerStart, innerEnd);
      }
    }

    return undefined;
  }

  /**
   * Check if a node is a quote delimiter in a string.
   */
  private isQuoteNode(node: Node): boolean {
    return (
      node.type === '"' ||
      node.type === "'" ||
      node.type === '`' ||
      node.type === '"""' ||
      node.type === "'''" ||
      node.type === "string_start" ||
      node.type === "string_end"
    );
  }

  /**
   * For nodes with bracket delimiters as first/last children,
   * return the range of the inner content (between the brackets).
   */
  private getBracketInnerRange(node: Node): vscode.Range | undefined {
    if (node.childCount < 2) return undefined;

    const firstChild = node.child(0);
    const lastChild = node.child(node.childCount - 1);

    if (!firstChild || !lastChild) return undefined;

    // Check if first and last children are bracket-like delimiters
    const firstIsBracket = BRACKET_TYPES.has(firstChild.type) || firstChild.type === "#{";
    const lastIsBracket = BRACKET_TYPES.has(lastChild.type);

    if (!firstIsBracket || !lastIsBracket) return undefined;

    const innerStart = new vscode.Position(
      firstChild.endPosition.row,
      firstChild.endPosition.column
    );
    const innerEnd = new vscode.Position(
      lastChild.startPosition.row,
      lastChild.startPosition.column
    );

    if (innerStart.isBefore(innerEnd)) {
      return new vscode.Range(innerStart, innerEnd);
    }

    return undefined;
  }
}
