# Installation and replacement instructions

Artifact:

`/home/qqq/_A001/_scr/_dot/tech/vscode/extension/php-smart-select/artifacts/tree-sitter-smart-select-patched-0.1.0.vsix`

## Recommended safe replacement

1. Leave `awesometaro.tree-sitter-smart-select` installed temporarily.
2. Install `local-alina.tree-sitter-smart-select-patched` from the VSIX.
3. Run **Developer: Reload Window** from the Command Palette.
4. Open a PHP file, place the cursor inside an expression, and verify repeated `Ctrl+E` expands through meaningful PHP syntax ranges and `Ctrl+Q` shrinks them.
5. After PHP verification succeeds, disable or uninstall `awesometaro.tree-sitter-smart-select`. Do not keep both enabled because competing selection providers can produce inconsistent selection chains.

## Install using the VS Code interface

1. Open Extensions.
2. Open **Views and More Actions (…)**.
3. Select **Install from VSIX…**.
4. Choose `tree-sitter-smart-select-patched-0.1.0.vsix` from the artifact directory above.
5. Run **Developer: Reload Window**.

## Install from the command line

```bash
code --install-extension /home/qqq/_A001/_scr/_dot/tech/vscode/extension/php-smart-select/artifacts/tree-sitter-smart-select-patched-0.1.0.vsix --force
```

Then run **Developer: Reload Window** and perform the PHP check before disabling the upstream extension.

## Updating

This local extension is protected from accidental upstream Marketplace updates because its ID is `local-alina.tree-sitter-smart-select-patched`. Updates are manual: build or obtain a newer versioned VSIX, verify it, and install it with `--force`.

## Uninstall and rollback

To uninstall the custom extension:

```bash
code --uninstall-extension local-alina.tree-sitter-smart-select-patched
```

For rollback, re-enable or reinstall `awesometaro.tree-sitter-smart-select`, disable the custom extension, and run **Developer: Reload Window**. Your `treeSitterSmartSelect.*` settings and `Ctrl+E`/`Ctrl+Q` keybindings remain compatible.
