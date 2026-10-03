import * as esbuild from 'esbuild';

await esbuild.build({
  entryPoints: ['src/extension.ts'],
  bundle: true,
  outfile: 'dist/extension.js',
  external: ['vscode'],
  format: 'cjs',
  platform: 'node',
  target: 'node20',
  sourcemap: true,
  minify: true,
  banner: {
    js: 'const __treeSitterImportMetaUrl = require("node:url").pathToFileURL(__filename).href;',
  },
  define: {
    'import.meta.url': '__treeSitterImportMetaUrl',
  },
});
