# Tree-sitter Smart Select — Patched Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone, locally maintained VS Code extension that replaces the upstream Tree-sitter Smart Select extension, supports all 16 original languages, and treats working PHP selection as a release requirement.

**Architecture:** Preserve the upstream TypeScript component boundaries: activation, parser management, language mapping, tree caching, and selection-range construction. Bundle the extension as CommonJS with esbuild while explicitly defining a valid file URL for the bundled `web-tree-sitter` runtime, avoiding the upstream `createRequire(undefined)` failure without post-processing generated JavaScript.

**Tech Stack:** TypeScript, VS Code Extension API, `web-tree-sitter`, Tree-sitter WASM grammars, esbuild, Mocha, `@vscode/vsce`.

**Spec:** `docs/superpowers/specs/2026-10-03-tree-sitter-smart-select-patched-design.md`

## Global Constraints

- Project root: `/home/qqq/_A001/_scr/_dot/tech/vscode/extension/php-smart-select`.
- Extension identifier: `local-alina.tree-sitter-smart-select-patched`.
- Initial version: `0.1.0`.
- Support all 16 language IDs from the specification.
- PHP grammar loading, parsing, and nested selection tests are release-blocking.
- Preserve the `treeSitterSmartSelect.*` configuration namespace.
- Do not assign or replace keyboard shortcuts.
- Do not modify the ALINA repository.
- Do not create a Git commit.
- Ask for explicit permission immediately before any JavaScript build command.
- Preserve the upstream MIT license and attribution.

## Review Focus

- A supported document opened before activation must still cause initialization and provider registration; covered by the activation test in Task 2.
- Missing or unreadable grammar WASM must return a controlled failure rather than crash the extension host; covered by parser-manager tests in Task 3.
- PHP files containing mixed HTML and PHP must parse and return nested PHP ranges; covered by the PHP integration fixture in Task 4.
- Files larger than `maxFileSize` must return no custom selection ranges; covered by provider tests in Task 4.
- Installing alongside the upstream extension must be clearly discouraged to prevent competing providers; covered by README verification in Task 6.

---

### Task 1: Reconstruct the maintained source project

**Files:**
- Create: `package.json`
- Create: `tsconfig.json`
- Create: `esbuild.mjs`
- Create: `.vscodeignore`
- Create: `src/extension.ts`
- Create: `src/parserManager.ts`
- Create: `src/languageMap.ts`
- Create: `src/treeCache.ts`
- Create: `src/selectionRangeProvider.ts`
- Create: `LICENSE`
- Create: `UPSTREAM.md`

**Interfaces:**
- Produces: `activate(context: vscode.ExtensionContext): Promise<void>` and `deactivate(): void`.
- Produces: `ParserManager`, `TreeCache`, and `TreeSitterSelectionRangeProvider` for later tests.

- [ ] **Step 1: Add a metadata test** asserting the extension ID components, version `0.1.0`, all 16 activation events, all four configuration keys, and absence of contributed keyboard shortcuts.
- [ ] **Step 2: Run the metadata test and verify it fails because `package.json` is absent.**
- [ ] **Step 3: Restore the upstream TypeScript sources from the installed source map, retaining component boundaries and MIT attribution.**
- [ ] **Step 4: Create package and TypeScript metadata with publisher `local-alina`, name `tree-sitter-smart-select-patched`, and the specified configuration namespace.**
- [ ] **Step 5: Restore the upstream esbuild baseline with `platform: "node"` and `format: "cjs"`; defer the runtime-URL correction until its failing regression test exists in Task 2.**
- [ ] **Step 6: Run the metadata test and verify it passes without running the JavaScript build.**

### Task 2: Prove activation uses a valid Tree-sitter runtime URL

**Files:**
- Create: `test/mocks/vscode.js`
- Create: `test/activation.test.cjs`
- Modify: `esbuild.mjs`

**Interfaces:**
- Consumes: `activate(context)` from Task 1.
- Produces: reusable VS Code mock state containing registered selection providers and displayed warnings.

- [ ] **Step 1: Write an activation test that loads the built extension, supplies an absolute extension URI, and asserts no warning plus exactly one provider covering all 16 language IDs.**
- [ ] **Step 2: Add a static bundle assertion rejecting `createRequire(undefined)`, an empty-object `.url` placeholder, or any equivalent undefined module URL.**
- [ ] **Step 3: With explicit user permission obtained immediately before the command, run the build and verify the test initially exposes any unresolved runtime-URL failure.**
- [ ] **Step 4: Apply the minimal esbuild `import.meta.url` definition/banner adjustment needed for a valid CommonJS file URL.**
- [ ] **Step 5: Rebuild with the same explicit permission and verify the activation and bundle assertions pass.**

### Task 3: Verify every grammar and parser failure behavior

**Files:**
- Create: `test/parserManager.test.ts`
- Create: `scripts/verify-wasm-assets.cjs`
- Create: `dist/wasm/tree-sitter.wasm`
- Create: `dist/wasm/tree-sitter-*.wasm`
- Modify: `src/parserManager.ts`
- Modify: `src/languageMap.ts`

**Interfaces:**
- Consumes: `ParserManager.initialize()`, `getLanguage(languageId)`, and `parse(source, languageId)`.
- Produces: verified runtime asset set and parser behavior for all declared languages.

- [ ] **Step 1: Write a failing asset test asserting the core runtime plus every grammar declared by `languageMap` exists and is non-empty.**
- [ ] **Step 2: Write a failing parser test asserting PHP source produces a Tree with a `program` root.**
- [ ] **Step 3: Write a failure-path test asserting an unavailable custom grammar is logged and handled without terminating the extension host.**
- [ ] **Step 4: Copy the version-matched core runtime and all 15 grammar WASM files used by the 16 language IDs into `dist/wasm`.**
- [ ] **Step 5: Implement only the parser-manager error handling required by the tests.**
- [ ] **Step 6: Run the asset and parser tests and verify all pass.**

### Task 4: Make PHP selection a release gate

**Files:**
- Create: `test/fixtures/php/mixed.php`
- Create: `test/selectionRangeProvider.test.ts`
- Modify: `src/selectionRangeProvider.ts`
- Modify: `src/treeCache.ts`

**Interfaces:**
- Consumes: `TreeSitterSelectionRangeProvider.provideSelectionRanges(document, positions, token)`.
- Produces: AST-derived nested `vscode.SelectionRange` chains.

- [ ] **Step 1: Add a mixed HTML/PHP fixture containing a class method, function call, array access, conditional block, and string literal.**
- [ ] **Step 2: Write a failing integration test asserting a cursor inside the PHP expression yields strictly expanding nested ranges ending at the document root.**
- [ ] **Step 3: Write tests for string-inner ranges, bracket-inner ranges, anonymous-node configuration, and multi-cursor results.**
- [ ] **Step 4: Write a size-limit test asserting a document beyond `maxFileSize` returns an empty result.**
- [ ] **Step 5: Implement the minimal range and cache behavior required by those tests.**
- [ ] **Step 6: Run the complete test suite and require every PHP test to pass.**

### Task 5: Package and inspect the standalone VSIX

**Files:**
- Create: `scripts/verify-vsix.cjs`
- Create: `artifacts/tree-sitter-smart-select-patched-0.1.0.vsix`
- Modify: `package.json`
- Modify: `.vscodeignore`

**Interfaces:**
- Consumes: passing build and tests from Tasks 1–4.
- Produces: installable versioned VSIX.

- [ ] **Step 1: Write a package-verification script that fails when identity metadata, extension bundle, core runtime, PHP grammar, any declared grammar, license, or README is absent from the VSIX.**
- [ ] **Step 2: With explicit user permission obtained immediately before the command, run the packaging command.**
- [ ] **Step 3: Run `scripts/verify-vsix.cjs` against the produced artifact and verify all required entries pass.**
- [ ] **Step 4: Extract the VSIX into a temporary directory and run the activation test against the extracted extension.**
- [ ] **Step 5: Confirm the packaged bundle has no undefined module URL pattern and the packaged PHP parser passes the fixture test.**

### Task 6: Document replacement installation and rollback

**Files:**
- Create: `README.md`
- Create: `INSTALL.md`

**Interfaces:**
- Consumes: final artifact path and extension IDs.
- Produces: complete GUI and CLI installation, verification, upgrade, uninstall, and rollback instructions.

- [ ] **Step 1: Write an instruction-content test asserting both extension IDs, the absolute VSIX path pattern, GUI installation steps, CLI installation command, reload step, shortcut behavior, conflict warning, and rollback steps are present.**
- [ ] **Step 2: Run it and verify it fails while documentation is missing.**
- [ ] **Step 3: Document installing the VSIX first, verifying PHP expand/shrink, and only then disabling or uninstalling `awesometaro.tree-sitter-smart-select`.**
- [ ] **Step 4: Document protection from upstream updates, manual upgrades, uninstalling the custom extension, and restoring the upstream extension.**
- [ ] **Step 5: Run documentation checks plus the full test and VSIX verification suite.**
- [ ] **Step 6: Report the artifact path, verification evidence, and the fact that no Git commit was created.**
