# SDD ledger — plan: /home/qqq/_A001/_scr/_dot/tech/vscode/extension/php-smart-select/docs/superpowers/plans/2026-10-03-tree-sitter-smart-select-patched.md

Ruling: The destination is not a Git repository and the specification forbids commits — use `/tmp/php-smart-select-work` as the implementation workspace and copy verified outputs into the destination — cost if wrong: task history is recorded in this ledger rather than Git history.

Pre-flight: Task 1 produces activation/parser/provider interfaces consumed by Tasks 2–4; names are consistent.
Pre-flight: Tasks 2–4 produce the verified bundle and tests consumed by Task 5; package paths are consistent.
Pre-flight: Task 5 produces the VSIX artifact path consumed by Task 6; version and identity are consistent.

Task 1: Ruling: the published upstream repository is empty — reconstruct the five TypeScript sources from the published 0.1.0 source map and document provenance — cost if wrong: future upstream history is unavailable locally.
Task 1: Ruling: `Parser.Tree` in recovered `treeCache.ts` contradicts its imported `Tree` type — use `Tree` to match web-tree-sitter 0.26.5 — cost if wrong: only the declared return type changes.
Task 1: complete (no commits by specification; tests: `npm run check && node test/metadata.test.cjs` → typecheck clean, 1/1 pass).

Task 2: Ruling: activation needs the core WASM before Task 3 copies the full asset set — copy only `tree-sitter.wasm` early so the URL regression test can isolate initialization — cost if wrong: asset setup crosses a task boundary but remains version-matched.
Task 2: complete (no commits by specification; tests: baseline activation 0/2 with `createRequire(undefined)`, corrected activation 2/2 pass).

Task 3: complete (no commits by specification; tests: 16/16 WASM assets present, PHP parse 1/1 pass, invalid custom PHP grammar fallback 1/1 pass, activation regression 2/2 pass).

Task 4: Ruling: restored upstream selection behavior already satisfies the new PHP integration tests without implementation changes — retain it as characterized behavior rather than alter working code — cost if wrong: behavior depends on the recovered 0.1.0 provider implementation.
Task 4: complete (no commits by specification; tests: mixed PHP nested/multi-cursor/string/bracket coverage and max-size behavior 2/2 pass).

Task 5: Ruling: VSCE rejects relative README links when a local-only extension has no repository URL — use a plain `INSTALL.md` filename rather than invent a misleading public repository — cost if wrong: the Marketplace-style README does not provide a clickable remote link.
Task 5: Ruling: the same VSCE constraint applies to every relative README link — render `LICENSE` and `UPSTREAM.md` as filenames too — cost if wrong: local documentation remains readable but links are not clickable in a Marketplace renderer.
Task 5: Ruling: VSCE canonicalizes package filenames to `LICENSE.txt` and `readme.md` — verify those archive names while retaining source filenames — cost if wrong: verification is coupled to VSCE's documented packaging normalization.
Task 5: complete (no commits by specification; VSIX has 23/23 required entries, extracted activation 2/2 pass, extracted PHP parse 1/1 pass).

Task 6: complete (no commits by specification; installation/replacement/rollback documentation test 1/1 pass).

Final review: self-review (native execution selected; no subagent review).
Final: minor (deferred): Parenthesize the triple-quoted-string fallback condition in `selectionRangeProvider.ts`; current precedence can classify a short `'''` or ``` prefix as a three-character quote, but produces no invalid range and does not affect tested PHP quoting.
Final verification: destination sources byte-match the typechecked workspace; destination suite 8/8 tests pass; VSIX 23/23 required entries pass; production dependency audit reports 0 vulnerabilities.
