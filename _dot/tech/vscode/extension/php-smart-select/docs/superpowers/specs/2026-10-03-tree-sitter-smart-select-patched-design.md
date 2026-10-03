# Tree-sitter Smart Select — Patched: Design Specification

Date: 2026-10-03

## Purpose

Create a maintainable, independently installable VS Code extension that provides AST-aware expand/shrink selection without a paid dependency. It retains all languages supported by the upstream Tree-sitter Smart Select extension and permanently fixes the CommonJS bundle initialization failure observed in VS Code.

## Identity and location

- Project directory: `/home/qqq/_A001/_scr/_dot/tech/vscode/extension/php-smart-select`
- Extension identifier: `local-alina.tree-sitter-smart-select-patched`
- Display name: `Tree-sitter Smart Select — Patched`
- Package format: versioned VSIX
- Initial version: `0.1.0`

The unique identifier prevents Marketplace updates to the upstream extension from overwriting this fork.

This extension is a standalone replacement for `awesometaro.tree-sitter-smart-select`, not an add-on. After the custom VSIX is installed and verified, the upstream extension should be disabled or uninstalled so that only one selection-range provider supplies Tree-sitter ranges for the supported languages. The custom extension's distinct identifier is not published in the Marketplace and therefore is not replaced by upstream Marketplace updates.

## Supported languages

The extension supports the original 16 VS Code language identifiers:

- TypeScript and TSX
- JavaScript and JSX
- Python
- Rust
- Go
- C and C++
- Java
- Ruby
- HTML
- CSS
- JSON
- Bash/Shell
- PHP

PHP support is release-blocking. A package must not be released when the PHP grammar is absent, cannot initialize, cannot parse the PHP fixture, or cannot produce the expected nested selection ranges.

## Behavior

The extension registers a VS Code `SelectionRangeProvider` for enabled languages. It parses the active document with the bundled Tree-sitter WASM runtime and the appropriate grammar, then builds a nested selection chain from the syntax node at each cursor position to the document root.

Selection ranges include meaningful named syntax nodes. Existing optional behavior for anonymous punctuation nodes, bracket interiors, and string interiors remains configurable. The extension continues using VS Code's standard commands:

- `editor.action.smartSelect.expand`
- `editor.action.smartSelect.shrink`

It does not assign or replace keyboard shortcuts. Existing user shortcuts such as `Ctrl+E` and `Ctrl+Q` continue to work.

## Configuration

Preserve these settings:

- `treeSitterSmartSelect.enabledLanguages`
- `treeSitterSmartSelect.additionalParsers`
- `treeSitterSmartSelect.maxFileSize`
- `treeSitterSmartSelect.includeAnonymousNodes`

The configuration namespace remains compatible with the upstream extension so existing settings continue to apply.

## Initialization fix

The upstream `web-tree-sitter` ESM runtime references `import.meta.url`. Bundling it directly as CommonJS with esbuild replaced that value with an undefined placeholder, causing `createRequire(undefined)` during extension activation.

The fork will keep application source separate from generated output and make the Tree-sitter runtime URL explicit at build/runtime boundaries. The build must produce a CommonJS VS Code extension bundle that initializes Tree-sitter using an absolute path to the bundled `tree-sitter.wasm`. The generated package must not contain the broken `createRequire(undefined)` pattern.

If the installed `web-tree-sitter` version cannot be bundled safely under that constraint, it will be treated as an external runtime dependency copied into the VSIX rather than inlined. Direct post-build edits of minified JavaScript are not part of the maintained solution.

## Project contents

The project will contain:

- TypeScript sources for activation, parser management, language mapping, tree caching, and selection-range construction.
- Bundled Tree-sitter runtime and language grammar WASM files.
- Package metadata and reproducible build/package scripts.
- Automated unit and activation tests.
- MIT license and upstream attribution.
- README with usage, configuration, build, installation, update, uninstall, and troubleshooting instructions.
- A versioned VSIX artifact.

## Testing and verification

Automated checks will verify:

1. The extension activates without a Tree-sitter initialization warning.
2. A selection provider is registered for PHP and every other supported language.
3. The PHP grammar loads and parses representative PHP code.
4. Selection expansion produces a nested AST-derived range chain for representative PHP expressions and blocks.
5. The packaged VSIX contains the extension bundle, core Tree-sitter runtime, and every declared grammar, including the required PHP grammar.
6. The generated bundle does not contain the known undefined-module-URL failure pattern.

Any PHP-specific failure fails the release verification and prevents the VSIX from being presented as ready for installation.

The VSIX will be installed locally only after package verification. The currently installed manually patched upstream extension will not be removed or disabled automatically.

## Installation experience

The README will document both methods:

1. VS Code UI: **Extensions → Views and More Actions (…) → Install from VSIX…**
2. Command line: `code --install-extension <absolute-path-to-vsix> --force`

After installation, users reload the VS Code window and invoke their existing expand/shrink shortcuts in a supported file.

The installation guide will explicitly instruct users to disable or uninstall `awesometaro.tree-sitter-smart-select` after the custom replacement is verified. It will also document how to restore the upstream extension if rollback is needed.

## Constraints

- Do not create a Git commit.
- Do not modify the ALINA repository.
- Do not run a JavaScript build until the user gives immediate, explicit permission directly before that build.
- Preserve upstream MIT licensing and attribution.
- Avoid unrelated features and configuration changes.
