import * as vscode from "vscode";
import { ParserManager } from "./parserManager";
import { TreeCache } from "./treeCache";
import { TreeSitterSelectionRangeProvider } from "./selectionRangeProvider";
import { getSupportedLanguageIds } from "./languageMap";

export { ParserManager } from "./parserManager";

let parserManager: ParserManager | undefined;
let treeCache: TreeCache | undefined;
let disposables: vscode.Disposable[] = [];

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  const config = vscode.workspace.getConfiguration("treeSitterSmartSelect");

  // Initialize parser manager
  parserManager = new ParserManager(context.extensionUri);

  try {
    await parserManager.initialize();
  } catch (err) {
    vscode.window.showWarningMessage(
      `Tree-sitter Smart Select: Failed to initialize. Selection expansion will use VS Code's built-in provider. Error: ${err}`
    );
    return;
  }

  // Initialize tree cache
  treeCache = new TreeCache(parserManager);
  treeCache.activate();

  // Get configuration
  const enabledLanguages = config.get<string[]>(
    "enabledLanguages",
    getSupportedLanguageIds()
  );
  const maxFileSize = config.get<number>("maxFileSize", 1048576);
  const includeAnonymousNodes = config.get<boolean>("includeAnonymousNodes", false);

  // Create the selection range provider
  const provider = new TreeSitterSelectionRangeProvider(
    treeCache,
    maxFileSize,
    includeAnonymousNodes
  );

  // Build document selector from enabled languages
  const documentSelector: vscode.DocumentFilter[] = enabledLanguages.map((lang) => ({
    language: lang,
  }));

  // Register the selection range provider
  if (documentSelector.length > 0) {
    const registration = vscode.languages.registerSelectionRangeProvider(
      documentSelector,
      provider
    );
    context.subscriptions.push(registration);
  }

  // Listen for configuration changes
  const configWatcher = vscode.workspace.onDidChangeConfiguration((e) => {
    if (e.affectsConfiguration("treeSitterSmartSelect")) {
      // Refresh custom parsers if configuration changed
      parserManager?.refreshCustomParsers();

      // Invalidate tree cache since settings may have changed
      if (
        e.affectsConfiguration("treeSitterSmartSelect.enabledLanguages") ||
        e.affectsConfiguration("treeSitterSmartSelect.additionalParsers")
      ) {
        treeCache?.invalidateAll();
        // Note: Re-registration of the provider would require a reload.
        // We show a message suggesting reload for language changes.
        vscode.window
          .showInformationMessage(
            "Tree-sitter Smart Select: Language settings changed. Reload the window to apply.",
            "Reload"
          )
          .then((choice) => {
            if (choice === "Reload") {
              vscode.commands.executeCommand("workbench.action.reloadWindow");
            }
          });
      }
    }
  });

  context.subscriptions.push(configWatcher);
  context.subscriptions.push({ dispose: () => deactivateInternal() });

  const langCount = documentSelector.length;
  console.log(
    `[tree-sitter-smart-select] Activated for ${langCount} language(s): ${enabledLanguages.join(", ")}`
  );
}

function deactivateInternal(): void {
  treeCache?.dispose();
  treeCache = undefined;

  parserManager?.dispose();
  parserManager = undefined;

  for (const d of disposables) {
    d.dispose();
  }
  disposables = [];
}

export function deactivate(): void {
  deactivateInternal();
}
