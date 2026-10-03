# Install:
```
code --install-extension ./artifacts/tree-sitter-smart-select-patched-0.1.0.vsix --force
```

# Tree-sitter Smart Select — Patched

A locally maintained, MIT-licensed replacement for `awesometaro.tree-sitter-smart-select`. It provides AST-aware expand/shrink selection for TypeScript, TSX, JavaScript, JSX, Python, Rust, Go, C, C++, Java, Ruby, HTML, CSS, JSON, Bash, and PHP.

The extension ID is `local-alina.tree-sitter-smart-select-patched`. Because it has a distinct local ID, Marketplace updates to the upstream extension cannot overwrite it.

## Shortcuts

This extension registers a selection provider but does not change keyboard shortcuts. It uses VS Code's standard commands:

- Expand: `editor.action.smartSelect.expand` (currently mapped to `Ctrl+E` on this machine)
- Shrink: `editor.action.smartSelect.shrink` (currently mapped to `Ctrl+Q` on this machine)

## PHP guarantee

PHP is release-blocking. The release checks require the PHP grammar to be packaged, initialize successfully, parse mixed HTML/PHP, fall back from an invalid custom grammar, and return nested AST-based selection ranges.

## Installation

See `INSTALL.md`. Install and verify this custom extension before disabling or uninstalling the upstream extension.

## Settings

Existing settings remain compatible:

- `treeSitterSmartSelect.enabledLanguages`
- `treeSitterSmartSelect.additionalParsers`
- `treeSitterSmartSelect.maxFileSize`
- `treeSitterSmartSelect.includeAnonymousNodes`

## Development

```bash
npm install --ignore-scripts
npm run check
npm run build
npm test
```

Build and package commands require explicit approval in the ALINA working environment. The CommonJS build maps `import.meta.url` to a real file URL derived from `__filename`, preventing the upstream `createRequire(undefined)` activation failure.

## License and provenance

MIT licensed. See `LICENSE` and `UPSTREAM.md` in the extension source directory.
