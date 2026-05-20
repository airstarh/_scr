// Place your key bindings in this file to override the defaults
[
  {
    key: "alt+f",
    command: "workbench.files.action.showActiveFileInExplorer",
  },
  {
    key: "ctrl+alt+numpad8",
    command: "commandId",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+numpad8",
    command: "commandId",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+numpad8",
    command: "commandId",
    when: "editorTextFocus",
  },
  {
    key: "f11",
    command: "bookmarks.toggle",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+numpad8",
    command: "commandId",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+k",
    command: "-bookmarks.toggle",
    when: "editorTextFocus",
  },
  {
    key: "shift+f11",
    command: "bookmarks.listFromAllFiles",
  },
  {
    key: "alt+t",
    command: "editor.action.smartSelect.expand",
    when: "editorTextFocus",
  },
  {
    key: "shift+alt+right",
    command: "-editor.action.smartSelect.expand",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+shift+alt+d",
    command: "php-docblocker.trigger",
  },
  {
    key: "ctrl+alt+l",
    command: "-editor.action.formatDocument",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+alt+l",
    command: "-editor.action.formatDocument",
    when: "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+shift+backspace",
    command: "workbench.action.navigateToLastEditLocation",
  },
  {
    key: "ctrl+k ctrl+q",
    command: "-workbench.action.navigateToLastEditLocation",
  },
  {
    key: "ctrl+k ctrl+f",
    command: "-editor.action.formatSelection",
    when: "editorHasDocumentSelectionFormattingProvider && editorTextFocus && !editorReadonly",
  },
  {
    key: "alt+x",
    command: "editor.action.formatSelection",
    when: "editorHasDocumentFormattingProvider && editorHasSelection && editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+alt+l",
    command: "-editor.action.formatSelection",
    when: "editorHasDocumentFormattingProvider && editorHasSelection && editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+numpad1",
    command: "extension.insertSemicolon",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+/",
    command: "-extension.insertSemicolon",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+shift+/",
    command: "-extension.insertSemicolonWithNewLine",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+numpad9",
    command: "bookmarks.jumpToNext",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+l",
    command: "-bookmarks.jumpToNext",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+numpad7",
    command: "bookmarks.jumpToPrevious",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+j",
    command: "-bookmarks.jumpToPrevious",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+numpad2",
    command: "namespaceResolver.import",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+i",
    command: "-namespaceResolver.import",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+numpad3",
    command: "phpdoc-generator.generatePHPDoc",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+enter",
    command: "-phpdoc-generator.generatePHPDoc",
    when: "editorTextFocus",
  },
  {
    key: "alt+v",
    command: "expand-selection-to-scope.expand",
  },
  {
    key: "alt+f11",
    command: "workbench.action.toggleFullScreen",
    when: "!isIOS",
  },
  {
    key: "f11",
    command: "-workbench.action.toggleFullScreen",
    when: "!isIOS",
  },
  {
    key: "ctrl+alt+numpad2",
    command: "workbench.action.toggleZenMode",
    when: "!isAuxiliaryWindowFocusedContext",
  },
  {
    key: "ctrl+k z",
    command: "-workbench.action.toggleZenMode",
    when: "!isAuxiliaryWindowFocusedContext",
  },
  {
    key: "ctrl+alt+scrolllock",
    command: "workbench.action.pinEditor",
    when: "!activeEditorIsPinned",
  },
  {
    key: "ctrl+k shift+enter",
    command: "-workbench.action.pinEditor",
    when: "!activeEditorIsPinned",
  },
  {
    key: "ctrl+alt+scrolllock",
    command: "workbench.action.unpinEditor",
    when: "activeEditorIsPinned",
  },
  {
    key: "ctrl+k shift+enter",
    command: "-workbench.action.unpinEditor",
    when: "activeEditorIsPinned",
  },
  {
    key: "ctrl+shift+alt+win+k",
    command: "git.commitAll",
    when: "!inDebugMode && !operationInProgress && !terminalFocus",
  },
  {
    key: "ctrl+k",
    command: "-git.commitAll",
    when: "!inDebugMode && !operationInProgress && !terminalFocus",
  },
  {
    key: "ctrl+alt+oem_4",
    command: "workbench.action.navigateBackInEditLocations",
  },
  {
    key: "ctrl+alt+oem_6",
    command: "workbench.action.navigateForwardInEditLocations",
  },
  {
    key: "alt+win+s",
    command: "editor.action.trimTrailingWhitespace",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+k ctrl+x",
    command: "-editor.action.trimTrailingWhitespace",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+d",
    command: "-notebook.addFindMatchToSelection",
    when: "config.notebook.multiCursor.enabled && notebookCellEditorFocused && activeEditor == 'workbench.editor.notebook'",
  },
  {
    key: "ctrl+d",
    command: "-editor.action.addSelectionToNextFindMatch",
    when: "editorFocus",
  },
  {
    key: "alt+1",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+1",
    command: "-workbench.view.explorer",
    when: "editorFocus && viewContainer.workbench.view.explorer.enabled",
  },
  {
    key: "alt+a",
    command: "-editor.action.accessibilityHelpConfigureAssignedKeybindings",
    when: "accessibilityHelpIsShown && accessibleViewHasAssignedKeybindings",
  },
  {
    key: "alt+numpad1",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+numpad1",
    command: "-workbench.view.explorer",
    when: "editorFocus && viewContainer.workbench.view.explorer.enabled",
  },
  {
    key: "alt+numpad3",
    command: "-workbench.view.search",
    when: "workbench.view.search.active && !searchViewletVisible",
  },
  {
    key: "alt+numpad3",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "searchViewletVisible",
  },
  {
    key: "alt+numpad5",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+numpad5",
    command: "-workbench.view.debug",
    when: "editorFocus && viewContainer.workbench.view.debug.enabled",
  },
  {
    key: "alt+numpad9",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+numpad9",
    command: "-workbench.view.git",
    when: "editorFocus",
  },
  {
    key: "alt+3",
    command: "-workbench.view.search",
    when: "workbench.view.search.active && !searchViewletVisible",
  },
  {
    key: "alt+3",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "searchViewletVisible",
  },
  {
    key: "alt+5",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+5",
    command: "-workbench.view.debug",
    when: "editorFocus && viewContainer.workbench.view.debug.enabled",
  },
  {
    key: "alt+9",
    command: "-workbench.view.scm",
    when: "editorFocus && workbench.scm.active",
  },
  {
    key: "alt+9",
    command: "-workbench.action.toggleSidebarVisibility",
    when: "!editorFocus",
  },
  {
    key: "alt+0",
    command: "-workbench.action.lastEditorInGroup",
  },
  {
    key: "alt+numpad1",
    command: "workbench.action.openEditorAtIndex1",
  },
  {
    key: "alt+1",
    command: "-workbench.action.openEditorAtIndex1",
  },
  {
    key: "alt+numpad2",
    command: "workbench.action.openEditorAtIndex2",
  },
  {
    key: "alt+2",
    command: "-workbench.action.openEditorAtIndex2",
  },
  {
    key: "alt+numpad3",
    command: "workbench.action.openEditorAtIndex3",
  },
  {
    key: "alt+3",
    command: "-workbench.action.openEditorAtIndex3",
  },
  {
    key: "alt+numpad4",
    command: "workbench.action.openEditorAtIndex4",
  },
  {
    key: "alt+4",
    command: "-workbench.action.openEditorAtIndex4",
  },
  {
    key: "alt+numpad5",
    command: "workbench.action.openEditorAtIndex5",
  },
  {
    key: "alt+5",
    command: "-workbench.action.openEditorAtIndex5",
  },
  {
    key: "alt+numpad6",
    command: "workbench.action.openEditorAtIndex6",
  },
  {
    key: "alt+6",
    command: "-workbench.action.openEditorAtIndex6",
  },
  {
    key: "alt+numpad7",
    command: "workbench.action.openEditorAtIndex7",
  },
  {
    key: "alt+7",
    command: "-workbench.action.openEditorAtIndex7",
  },
  {
    key: "alt+numpad8",
    command: "workbench.action.openEditorAtIndex8",
  },
  {
    key: "alt+8",
    command: "-workbench.action.openEditorAtIndex8",
  },
  {
    key: "alt+numpad9",
    command: "workbench.action.openEditorAtIndex9",
  },
  {
    key: "alt+9",
    command: "-workbench.action.openEditorAtIndex9",
  },
  {
    key: "alt+j",
    command: "-editor.action.addSelectionToNextFindMatch",
    when: "editorFocus",
  },
  {
    key: "ctrl+k ctrl+t",
    command: "-workbench.action.selectTheme",
  },
  {
    key: "alt+a",
    command: "bracket-select.select",
    when: "editorTextFocus",
  },
  {
    key: "alt+a",
    command: "-bracket-select.select",
    when: "editorTextFocus",
  },
  {
    key: "alt+s",
    command: "bracket-select.select-include",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+a",
    command: "-brackedt-select.select-include",
    when: "editorTextFocus",
  },
  {
    key: "alt+z",
    command: "-bracket-select.undo-select",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+shift+l",
    command: "-addCursorsAtSearchResults",
    when: "fileMatchOrMatchFocus && searchViewletVisible",
  },
  {
    key: "shift+alt+i",
    command: "-editor.action.insertCursorAtEndOfEachLineSelected",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+down",
    command: "-editor.action.insertCursorBelow",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+=",
    command: "-workbench.action.zoomIn",
  },
  {
    key: "ctrl+=",
    command: "-editor.unfold",
    when: "editorFocus",
  },
  {
    key: "ctrl+1",
    command: "-workbench.action.focusFirstEditorGroup",
  },
  {
    key: "ctrl+3",
    command: "-workbench.action.focusThirdEditorGroup",
  },
  {
    key: "ctrl+4",
    command: "-workbench.action.focusFourthEditorGroup",
  },
  {
    key: "ctrl+5",
    command: "-workbench.action.focusFifthEditorGroup",
  },
  {
    key: "ctrl+6",
    command: "-workbench.action.focusSixthEditorGroup",
  },
  {
    key: "ctrl+7",
    command: "-workbench.action.focusSeventhEditorGroup",
  },
  {
    key: "ctrl+8",
    command: "-workbench.action.focusEighthEditorGroup",
  },
  {
    key: "ctrl+9",
    command: "-workbench.action.lastEditorInGroup",
  },
  {
    key: "ctrl+0",
    command: "-workbench.action.focusSideBar",
  },
  {
    key: "ctrl+shift+alt+c",
    command: "copyRelativeFilePath",
    when: "!editorFocus",
  },
  {
    key: "ctrl+k ctrl+shift+c",
    command: "-copyRelativeFilePath",
    when: "!editorFocus",
  },
  {
    key: "ctrl+shift+alt+c",
    command: "copyRelativeFilePath",
    when: "editorFocus",
  },
  {
    key: "ctrl+k ctrl+shift+c",
    command: "-copyRelativeFilePath",
    when: "editorFocus",
  },
  {
    key: "ctrl+shift+alt+f11",
    command: "codenotes.deleteSelectedNote",
  },
  {
    key: "shift+alt+f11",
    command: "ghostNote.openGhostNoteEditorAtCursorPosition",
  },
  {
    key: "shift+alt+z",
    command: "workbench.action.exitZenMode",
    when: "inZenMode",
  },
  {
    key: "escape escape",
    command: "-workbench.action.exitZenMode",
    when: "inZenMode",
  },
  {
    key: "ctrl+b",
    command: "-editor.action.goToDeclaration",
    when: "editorHasDefinitionProvider && editorTextFocus",
  },
  {
    key: "shift+win+d",
    command: "string-manipulation.dasherize",
  },
  {
    key: "shift+win+q",
    command: "string-manipulation.camelize",
  },
  {
    key: "ctrl+alt+numpad5",
    command: "workbench.action.focusActiveEditorGroup",
  },
  {
    key: "ctrl+alt+up",
    command: "-editor.action.insertCursorAbove",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+alt+up",
    command: "-workbench.action.chat.previousUserPrompt",
    when: "chatIsEnabled && inChat",
  },
  {
    key: "ctrl+alt+i",
    command: "-workbench.action.chat.open",
    when: "!chatSetupDisabled && !chatSetupHidden",
  },
  {
    key: "ctrl+alt+pageup",
    command: "-workbench.action.chat.previousCodeBlock",
    when: "chatIsEnabled && inChat",
  },
  {
    key: "ctrl+alt+down",
    command: "-workbench.action.chat.nextUserPrompt",
    when: "chatIsEnabled && inChat",
  },
  {
    key: "ctrl+alt+pagedown",
    command: "-workbench.action.chat.nextCodeBlock",
    when: "chatIsEnabled && inChat",
  },
  {
    key: "ctrl+alt+y",
    command: "-chatEditor.action.acceptAllEdits",
    when: "chatEdits.hasEditorModifications && editorFocus && !chatEdits.isCurrentlyBeingModified || chatEdits.hasEditorModifications && notebookEditorFocused && !chatEdits.isCurrentlyBeingModified",
  },
  {
    key: "ctrl+alt+enter",
    command: "-workbench.action.chat.runInTerminal",
    when: "accessibleViewInCodeBlock && chatIsEnabled || chatIsEnabled && inChat",
  },
  {
    key: "ctrl+alt+/",
    command: "-workbench.action.chat.attach.instructions",
    when: "chatIsEnabled && config.chat.promptFiles",
  },
  {
    key: "ctrl+alt+d",
    command: "-sessions.delete",
  },
  {
    key: "ctrl+k ctrl+c",
    command: "-editor.action.addCommentLine",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+k m",
    command: "-workbench.action.editor.changeLanguageMode",
    when: "!notebookEditorFocused",
  },
  {
    key: "ctrl+k ctrl+alt+c",
    command: "-workbench.action.addComment",
    when: "activeCursorHasCommentingRange",
  },
  {
    key: "ctrl+k ctrl+alt+down",
    command: "-editor.action.nextCommentingRange",
    when: "accessibilityModeEnabled && commentFocused || accessibilityModeEnabled && editorFocus || accessibilityHelpIsShown && accessibilityModeEnabled && accessibleViewCurrentProviderId == 'comments'",
  },
  {
    key: "ctrl+k ctrl+alt+up",
    command: "-editor.action.previousCommentingRange",
    when: "accessibilityModeEnabled && commentFocused || accessibilityModeEnabled && editorFocus || accessibilityHelpIsShown && accessibilityModeEnabled && accessibleViewCurrentProviderId == 'comments'",
  },
  {
    key: "shift+f7",
    command: "-inlineChat.moveToPreviousHunk",
    when: "inlineChatHasProvider && inlineChatVisible",
  },
  {
    key: "ctrl+alt+numpad1",
    command: "atch.aligncode",
  },
  {
    key: "ctrl+v",
    command: "-editor.action.clipboardPasteAction",
  },
  {
    key: "shift+insert",
    command: "-editor.action.clipboardPasteAction",
  },
  {
    key: "ctrl+c",
    command: "-editor.action.clipboardCopyAction",
    when: "!terminalFocus",
  },
  {
    key: "ctrl+c",
    command: "-editor.action.clipboardCopyAction",
  },
  {
    key: "ctrl+insert",
    command: "-editor.action.clipboardCopyAction",
  },
  {
    key: "shift+delete",
    command: "-editor.action.clipboardCutAction",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+x",
    command: "-editor.action.clipboardCutAction",
    when: "!terminalFocus",
  },
  {
    key: "ctrl+x",
    command: "-editor.action.clipboardCutAction",
  },
  {
    key: "shift+delete",
    command: "-editor.action.clipboardCutAction",
  },
  {
    key: "ctrl+shift+delete",
    command: "editor.emmet.action.removeTag",
  },
  {
    key: "ctrl+alt+numpad3",
    command: "phpNamespaceHelper.import",
  },
  {
    key: "shift+alt+x",
    command: "editor.action.formatSelection.multiple",
  },
  {
    key: "ctrl+shift+right",
    command: "-cursorWordAccessibilityRightSelect",
    when: "accessibilityModeEnabled && isWindows && textInputFocus && focusedView == 'workbench.panel.output'",
  },
  {
    key: "ctrl+shift+left",
    command: "-cursorWordAccessibilityLeftSelect",
    when: "accessibilityModeEnabled && isWindows && textInputFocus && focusedView == 'workbench.panel.output'",
  },
  {
    key: "ctrl+left",
    command: "-cursorWordAccessibilityLeft",
    when: "accessibilityModeEnabled && isWindows && textInputFocus && focusedView == 'workbench.panel.output'",
  },
  {
    key: "ctrl+right",
    command: "-cursorWordAccessibilityRight",
    when: "accessibilityModeEnabled && isWindows && textInputFocus && focusedView == 'workbench.panel.output'",
  },
  {
    key: "shift+alt+right",
    command: "cursorWordStartRightSelect",
  },
  {
    key: "ctrl+f7",
    command: "editor.action.wordHighlight.next",
    when: "editorTextFocus && hasWordHighlights",
  },
  {
    key: "f7",
    command: "-editor.action.wordHighlight.next",
    when: "editorTextFocus && hasWordHighlights",
  },
  {
    key: "ctrl+[",
    command: "-editor.action.outdentLines",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+]",
    command: "-editor.action.indentLines",
    when: "editorTextFocus && !editorReadonly",
  },
  {
    key: "ctrl+[",
    command: "editor.action.jumpToBracket",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+shift+\\",
    command: "-editor.action.jumpToBracket",
    when: "editorTextFocus",
  },
  {
    key: "win+delete",
    command: "bookmarks.clearFromAllFiles",
  },
  {
    key: "shift+alt+l",
    command: "-bookmarks.expandSelectionToNext",
    when: "editorTextFocus",
  },
  {
    key: "shift+alt+j",
    command: "-bookmarks.expandSelectionToPrevious",
    when: "editorTextFocus",
  },
  {
    key: "shift+alt+k",
    command: "-bookmarks.shrinkSelection",
    when: "editorTextFocus",
  },
  {
    key: "ctrl+win+delete",
    command: "bookmarks.clear",
  },
  {
    key: "meta+f4",
    command: "workbench.action.closeActiveEditor",
  },
  {
    key: "ctrl+w",
    command: "-workbench.action.closeActiveEditor",
  },
  {
    key: "ctrl+f4",
    command: "-workbench.action.closeActiveEditor",
  },
  {
    key: "meta+f4",
    command: "workbench.action.closeActivePinnedEditor",
  },
];
