return {
    // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    // DANGER !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "update.enableWindowsBackgroundUpdates": false,
    "update.mode": "none",
    // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    //
    "vscode_custom_css.imports": [
        // "file:///C:/_A001/STATICA/vscode/001.css"
    ],
    //
    "window.title": "${rootName}",
    // region workbench.colorCustomizations
    "workbench.colorCustomizations": {
        // region ERROR
        // Errors (Ошибки)
        "editorError.background": "#ff0000dd", // Фон области с ошибкой в редакторе (если поддерживается темой)
        "errorBackground": "#ff0000", // Общий фон для элементов с ошибками в UI
        "inputValidation.errorBackground": "#ff0000", // Фон поля ввода с ошибкой
        "panel.errorBackground": "#ff0000", // Фон панели (Problems, Output и т. д.) при наличии ошибок
        "statusBar.errorBackground": "#ff0000", // Фон строки состояния при критической ошибке
        // Warnings (Предупреждения)
        "editorWarning.background": "#cf019180", // Фон области с предупреждением в редакторе
        "warningBackground": "#cf019180", // Общий фон для элементов с предупреждениями в UI
        "inputValidation.warningBackground": "#cf019180", // Фон поля ввода с предупреждением
        "panel.warningBackground": "#cf019180", // Фон панели при наличии предупреждений
        "statusBar.warningBackground": "#cf019180", // Фон строки состояния при предупреждении
        // Info (Информация/подсказки)
        // "editorInfo.background": "#E3F2FD", // Фон области с информационной подсказкой в редакторе
        // "infoBackground": "#E3F2FD", // Общий фон для информационных элементов в UI
        // "inputValidation.infoBackground": "#E3F2FD", // Фон поля ввода с информационным сообщением
        // "panel.infoBackground": "#E3F2FD", // Фон панели при наличии информационных сообщений
        // "statusBar.infoBackground": "#1976D2" // Фон строки состояния для информационных уведомлений
        //end region ERROR
        "editorCursor.foreground": "#ffffffff",
        "editorWhitespace.foreground": "#333333",
        "editorWhitespace.trailing.foreground": "#FF0000",
        // region THEME
        "contrastActiveBorder": "#830101", // FOR TABS
        "contrastBorder": "#ffffff", // FOR SEARCH BOX
        // endregion THEME
        // region EDITOR
        "editor.background": "#090909",
        // ####################################################################################################
        // region SEARCH FIND SELECTION LINE
        // region LINE
        "editorGutter.background": "#333333",
        //
        "editor.lineHighlightBackground": "#000077",
        "editor.lineHighlightBorder": "#000077",
        "editor.rangeHighlightBackground": "#000077ee",
        // STICKY LINE
        "editorStickyScroll.background": "#0000be",
        //
        "editorLineNumber.activeForeground": "#ffffff",
        "editorLineNumber.foreground": "#000000",
        // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        "git.blame.editorDecorationForeground": "#13c4cac0",
        // endregion LINE
        // ####################################################################################################
        // region FIND SEARCH
        // FIND SEARCH
        // FIND SEARCH BORDER
        "editor.findMatchBorder": "#ffffff00",
        "editor.findMatchHighlightBorder": "#ffffff00",
        // inactive search [ OTHER PLACES ]
        "editor.findMatchHighlightBackground": "#00fb00cc",
        "editor.findMatchForeground": "#0805c4",
        // active search [CURRENT FOUND CURSOR]
        "editor.findMatchBackground": "#cc8b00",
        "editor.findMatchHighlightForeground": "#0805c4ee",
        // endregion FIND SEARCH
        // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        // region WORD ACTIVE VARIABLES
        "editor.wordHighlightBackground": "#00000011",
        "editor.wordHighlightBorder": "#d48b03",
        // PRIORITY by some unknown reasons fuck!!!!:
        "editor.wordHighlightTextBackground": "#00000011",
        "editor.wordHighlightTextBorder": "#d48b03",
        //
        "editor.wordHighlightStrongBackground": "#00000033",
        "editor.wordHighlightStrongBorder": "#00000033",
        // region WORD ACTIVE VARIABLES
        // region SELECTION
        "editor.selectionBackground": "#f7f6f6fe",
        //
        "editor.selectionHighlightBackground": "#0000FFfe",
        "editor.selectionHighlightBorder": "#0000FFfe",
        // endregion SELECTION
        // endregion SEARCH FIND SELECTION LINE
        // HINTS
        "phpParameterHint.hintForeground": "#000000",
        "phpParameterHint.hintBackground": "#777777",
        "editorInlayHint.foreground": "#000000aa",
        "editorInlayHint.background": "#444444",
        // () [] {}
        "editorBracketHighlight.foreground1": "#ad99ff",
        "editorBracketHighlight.foreground2": "#ad99ff",
        "editorBracketHighlight.unexpectedBracket.foreground": "#ff0000",
        "editorBracketMatch.background": "#005c00",
        "editorBracketMatch.border": "#005c00",
        // BOOKMARK
        "bookmarks.lineBackground": "#be01018a",
        // EXTENSION: Breakpoint Highlight : https://marketplace.visualstudio.com/items?itemName=ericgomez.breakpoint-highlight
        "breakpointHighlight.backgroundColor": "#ffffff",
        // region INDENT
        "editorIndentGuide.activeBackground1": "#FF0000ff",
        "editorIndentGuide.activeBackground2": "#a06800",
        "editorIndentGuide.activeBackground3": "#FFFF00ff",
        "editorIndentGuide.activeBackground4": "#008000ff",
        "editorIndentGuide.activeBackground5": "#0000FFff",
        "editorIndentGuide.activeBackground6": "#EE82EEff",
        // non-active indent guide colors
        "editorIndentGuide.background1": "#FF0000ff",
        "editorIndentGuide.background2": "#a06800",
        "editorIndentGuide.background3": "#FFFF00ff",
        "editorIndentGuide.background4": "#008000ff",
        "editorIndentGuide.background5": "#0000FFff",
        "editorIndentGuide.background6": "#EE82EEff",
        // endregion INDENT
        // region DIFF
        "diffEditor.insertedLineBackground": "#057005c8",
        "diffEditor.removedLineBackground": "#78010199",
        "diffEditor.insertedTextBackground": "#1e018599",
        "diffEditor.insertedTextBorder": "#057005c8",
        "diffEditor.removedTextBackground": "#5c5a0099",
        "diffEditor.removedTextBorder": "#5c5a0099",
        "diffEditor.border": "#000000",
        "diffEditor.diagonalFill": "#00000099",
        "diffEditorGutter.insertedLineBackground": "#aaffaa99",
        "diffEditorGutter.removedLineBackground": "#ffaaff99",
        // endregion DIFF
        // endregion EDITOR
        // region NOT EDITOR
        // region TAB
        "tab.border": "#ffffff",
        "tab.activeBorder": "#830101",
        "tab.unfocusedActiveBorder": "#830101",
        "tab.activeBackground": "#830101",
        "tab.activeForeground": "#ffffff",
        "tab.inactiveBackground": "#333333",
        // endregion TAB
        // region BREADCRUMB
        "breadcrumb.foreground": "#aaaaaa",
        "breadcrumb.background": "#00530f",
        "breadcrumb.focusForeground": "#fe8c8c",
        "breadcrumb.activeSelectionForeground": "#27a9dd",
        "breadcrumbPicker.background": "#dde258",
        // endregion BREADCRUMB
        // region POPUP
        "editorHoverWidget.background": "#400068",
        "editorSuggestWidget.background": "#400068",
        "editorWidget.background": "#400068",
        "editorSuggestWidget.selectedBackground": "#400068",
        "editorHoverWidget.border": "#400068",
        "editorSuggestWidget.border": "#400068",
        "editorParameterHint.background": "#400068",
        "editorSuggestWidget.highlightForeground": "#000000",
        // endregion POPUP
        // region LIST, EXPLORER, FILES
        "list.inactiveSelectionBackground": "#444444",
        "list.inactiveSelectionForeground": "#aaaaaa",
        "list.activeSelectionBackground": "#072699",
        "list.focusBackground": "#2f2f2f",
        // endregion LIST, EXPLORER, FILES
        // region  INPUT COLORS
        "settings.numberInputBackground": "#66014c",
        "settings.textInputBackground": "#66014c",
        "settings.checkboxBackground": "#66014c",
        "settings.dropdownBackground": "#66014c",
        // INPUT
        /*
          https:                                                                                          //code.visualstudio.com/api/references/theme-color
          input.background:                  Input box background.
          input.border:                      Input box border.
          input.foreground:                  Input box foreground.
          input.placeholderForeground:       Input box foreground color for placeholder text.
          inputOption.activeBackground:      Background color of activated options in input fields.
          inputOption.activeBorder:          Border color of activated options in input fields.
          inputOption.activeForeground:      Foreground color of activated options in input fields.
          inputOption.hoverBackground:       Background color of activated options in input fields.
          inputValidation.errorBackground:   Input validation background color for error severity.
          inputValidation.errorForeground:   Input validation foreground color for error severity.
          inputValidation.errorBorder:       Input validation border color for error severity.
          inputValidation.infoBackground:    Input validation background color for information severity.
          inputValidation.infoForeground:    Input validation foreground color for information severity.
          inputValidation.infoBorder:        Input validation border color for information severity.
          inputValidation.warningBackground: Input validation background color for information warning.
          inputValidation.warningForeground: Input validation foreground color for warning severity.
          inputValidation.warningBorder:     Input validation border color for warning severity.
          Scrollbar control
        */
        "input.foreground": "#818181",
        "input.background": "#26004b",
        "button.background": "#0202a8",
        "button.hoverBackground": "#017301",
        // endregion INPUT COLORS
        // endregion NOT EDITOR
    },
    // endregion workbench.colorCustomizations
    // region COLOR BY TOKEN
    "editor.tokenColorCustomizations": {
        //"functions": "#a143ff",
        "textMateRules": [
            {
                "scope": "string.quoted.double",
                "settings": {
                    "foreground": "#eeff00",
                    "fontStyle": "bold"
                }
            },
            {
                "scope": "string.quoted.single",
                "settings": {
                    "foreground": "#eeff00",
                    "fontStyle": "bold"
                }
            },
            {
                "scope": "string.template",
                "settings": {
                    "foreground": "#eeff00",
                    "fontStyle": "bold"
                }
            },
            // {
            //     "scope": "entity.name.function",
            //     "settings": {
            //         "foreground": "#6fc3f8",
            //         "fontStyle": "bold"
            //     }
            // },
            {
                "scope": "variable.other",
                "settings": {
                    "foreground": "#2fff00"
                }
            },
            {
                "scope": "variable.other.constant",
                "settings": {
                    "foreground": "#ffffff",
                    // "background": "#ffffff33",
                }
            },
            {
                "scope": [
                    "comment",
                    "comment.block.documentation",
                    "comment.block.documentation.js",
                    "comment.line.double-slash.js",
                    "storage.type.class.jsdoc",
                    "entity.name.type.instance.jsdoc",
                    "variable.other.jsdoc",
                    "punctuation.definition.comment",
                    "punctuation.definition.comment.begin.documentation",
                    "punctuation.definition.comment.end.documentation"
                ],
                "settings": {
                    "foreground": "#00b7ff"
                }
            }
        ]
    },
    // endregion COLOR BY TOKEN
    // region HIGHLIGHT
    "highlight.regexes": {
        // region OWN HIGHLIGHTS
        "(\\[:.+?:\\]|\\{.*?\\})": {
            // "filterFileRegex": ".php",
            "decorations": [
                {
                    "overviewRulerColor": "#ffffff44",
                    "backgroundColor": "#ffffff44",
                    // "color": "#00000066",
                    "fontWeight": "bold"
                }
            ]
        },
        "([\\s]*)(private.*?|public.*?|protected.*?|static.*?|function.*?|fn.*?)(\\()": {
            // "filterFileRegex": ".php",
            "decorations": [
                {
                    // "backgroundColor": "#015897bb",
                },
                {
                    "backgroundColor": "#015897bb",
                    "overviewRulerColor": "#015897bb",
                    // "color": "#ffffff88",
                    "fontWeight": "bold",
                },
                {}
            ]
        },
        "(return|throw|exit|die|break|continue|yield)(.*?)": {
            // "filterFileRegex": ".php",
            "decorations": [
                {
                    "backgroundColor": "#aaffaa77",
                    "color": "#000000",
                    "fontWeight": "bold"
                },
                {
                    "backgroundColor": "#b1fd0052",
                }
            ]
        },
        "(\\s)(foreach|while|do|switch|case|default|for|region|endregion|unless)(\\ |\\(|\\:)": {
            // "filterFileRegex": ".php",
            "decorations": [
                {},
                {
                    "overviewRulerColor": "#015897bb",
                    "backgroundColor": "#015897bb",
                    // "color": "#ffffff88",
                    "fontWeight": "bold"
                },
                {}
            ]
        },
        "(console.log|//VA:|plog|xxx|XXX|QQQ|qqq|System::\\$Params|<input|assert|discount)": {
            // "filterFileRegex": ".php",
            "decorations": [
                {
                    "overviewRulerColor": "#0bbef9bd",
                    "backgroundColor": "#0bbef9bd",
                    "color": "#000000",
                    "fontWeight": "bold"
                }
            ]
        },
        "(onclick|onchange|onsubmit|onfocusout)": {
            // "filterFileRegex": ".php",
            "decorations": [
                {
                    "overviewRulerColor": "#0bbef9bd",
                    "backgroundColor": "#0bbef9bd",
                    "color": "#000000aa",
                    "fontWeight": "bold"
                }
            ]
        },
        // PHP CLASS METHODS CALL
        "(->|::)([a-z-A-Z-0-9]{1,}?)[(]": {
            "filterFileRegex": ".php",
            "decorations": [
                {},
                {
                    "overviewRulerColor": "#a001a040",
                    "backgroundColor": "#ff00ff40",
                    // "color": "#000000",
                    "fontWeight": "bold"
                }
            ]
        },
        // endregion OWN HIGHLIGHTS
        // region DEFAULTS
        "((?:<!-- *)?(?:#|// @|//|./\\*+|<!--|--|\\* @|{!|{{!--|{{!) *TODO(?:\\s*\\([^)]+\\))?:?)((?!\\w)(?: *-->| *\\*/| *!}| *--}}| *}}|(?= *(?:[^:]//|/\\*+|<!--|@|--|{!|{{!--|{{!))|(?: +[^\\n@]*?)(?= *(?:[^:]//|/\\*+|<!--|@|--(?!>)|{!|{{!--|{{!))|(?: +[^@\\n]+)?))": {
            "filterFileRegex": ".*(?<!CHANGELOG.md)$",
            "decorations": [
                {
                    "overviewRulerColor": "#ffcc00",
                    "backgroundColor": "#ffcc00",
                    "color": "#1f1f1f",
                    "fontWeight": "bold"
                },
                {
                    "backgroundColor": "#ffcc00",
                    "color": "#1f1f1f"
                }
            ]
        },
        "((?:<!-- *)?(?:#|// @|//|./\\*+|<!--|--|\\* @|{!|{{!--|{{!) *(?:FIXME|FIX|BUG|UGLY|DEBUG|HACK)(?:\\s*\\([^)]+\\))?:?)((?!\\w)(?: *-->| *\\*/| *!}| *--}}| *}}|(?= *(?:[^:]//|/\\*+|<!--|@|--|{!|{{!--|{{!))|(?: +[^\\n@]*?)(?= *(?:[^:]//|/\\*+|<!--|@|--(?!>)|{!|{{!--|{{!))|(?: +[^@\\n]+)?))": {
            "filterFileRegex": ".*(?<!CHANGELOG.md)$",
            "decorations": [
                {
                    "overviewRulerColor": "#cc0000",
                    "backgroundColor": "#cc0000",
                    "color": "#1f1f1f",
                    "fontWeight": "bold"
                },
                {
                    "backgroundColor": "#cc0000",
                    "color": "#1f1f1f"
                }
            ]
        },
        "((?:<!-- *)?(?:#|// @|//|./\\*+|<!--|--|\\* @|{!|{{!--|{{!) *(?:REVIEW|OPTIMIZE|TSC)(?:\\s*\\([^)]+\\))?:?)((?!\\w)(?: *-->| *\\*/| *!}| *--}}| *}}|(?= *(?:[^:]//|/\\*+|<!--|@|--|{!|{{!--|{{!))|(?: +[^\\n@]*?)(?= *(?:[^:]//|/\\*+|<!--|@|--(?!>)|{!|{{!--|{{!))|(?: +[^@\\n]+)?))": {
            "filterFileRegex": ".*(?<!CHANGELOG.md)$",
            "decorations": [
                {
                    "overviewRulerColor": "#00ccff",
                    "backgroundColor": "#00ccff",
                    "color": "#1f1f1f",
                    "fontWeight": "bold"
                },
                {
                    "backgroundColor": "#00ccff",
                    "color": "#1f1f1f"
                }
            ]
        },
        "((?:<!-- *)?(?:#|// @|//|./\\*+|<!--|--|\\* @|{!|{{!--|{{!) *(?:IDEA)(?:\\s*\\([^)]+\\))?:?)((?!\\w)(?: *-->| *\\*/| *!}| *--}}| *}}|(?= *(?:[^:]//|/\\*+|<!--|@|--|{!|{{!--|{{!))|(?: +[^\\n@]*?)(?= *(?:[^:]//|/\\*+|<!--|@|--(?!>)|{!|{{!--|{{!))|(?: +[^@\\n]+)?))": {
            "filterFileRegex": ".*(?<!CHANGELOG.md)$",
            "decorations": [
                {
                    "overviewRulerColor": "#cc00cc",
                    "backgroundColor": "#cc00cc",
                    "color": "#1f1f1f",
                    "fontWeight": "bold"
                },
                {
                    "backgroundColor": "#cc00cc",
                    "color": "#1f1f1f"
                }
            ]
        },
        // endregion DEFAULTS
    },
    // endregion HIGHLIGHT
    // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    // region CUSTOM
    "bookmarks.navigateThroughAllFiles": false,
    "json.format.keepLines": false,
    "workbench.hover.delay": 3000,
    "workbench.sash.hoverDelay": 2000,
    "editor.hover.delay": 10000,
    "editor.hover.hidingDelay": 100,
    "workbench.editor.pinnedTabsOnSeparateRow": true,
    "workbench.editor.wrapTabs": true,
    "workbench.tree.indent": 33,
    "files.autoSave": "onFocusChange",
    "editor.mouseWheelZoom": true,
    "editor.renderLineHighlight": "all",
    "workbench.tree.expandMode": "doubleClick",
    "workbench.list.openMode": "doubleClick",
    "workbench.list.smoothScrolling": true,
    "terminal.integrated.smoothScrolling": true,
    "editor.scrollbar.horizontal": "hidden",
    "editor.mouseWheelScrollSensitivity": 0.3,
    "workbench.tree.stickyScrollMaxItemCount": 33,
    "editor.scrollbar.horizontalScrollbarSize": 5,
    "editor.scrollbar.verticalScrollbarSize": 5,
    "workbench.editor.closeOnFileDelete": true,
    "explorer.confirmDelete": false,
    "explorer.confirmPasteNative": false,
    "explorer.confirmDragAndDrop": false,
    "diffEditor.ignoreTrimWhitespace": false,
    "editor.formatOnPaste": true,
    "editor.formatOnType": true,
    "editor.showFoldingControls": "always",
    "editor.smartSelect.selectLeadingAndTrailingWhitespace": false,
    "editor.smartSelect.selectSubwords": false,
    "workbench.tree.renderIndentGuides": "always",
    "workbench.view.alwaysShowHeaderActions": true,
    "explorer.autoReveal": false,
    "window.restoreFullscreen": true,
    "editor.autoIndent": "full",
    "workbench.list.horizontalScrolling": true,
    "explorer.copyPathSeparator": "/",
    "explorer.copyRelativePathSeparator": "/",
    "editor.fontFamily": "Cascadia Code ExtraLight",
    "editor.minimap.enabled": false,
    "editor.codeLens": false,
    "workbench.editor.openPositioning": "last",
    // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    // region SPELL
    "cSpell.language": "en,ru",
    "cSpell.userWords": [
        "ACHT",
        "ALINA",
        "alinapath",
        "anarki",
        "answ",
        "atts",
        "Azbuka",
        "Bootbox",
        "Certbot",
        "COEF",
        "Coeff",
        "CURLOPT",
        "Debet",
        "Devcasino",
        "devxa",
        "egamings",
        "etts",
        "fastcgi",
        "feeamount",
        "firstname",
        "Freebets",
        "Freeround",
        "Freerounds",
        "funcore",
        "fundist",
        "HTTPHEADER",
        "idekey",
        "intelephense",
        "Laravel",
        "lastname",
        "letsencrypt",
        "locklib",
        "maint",
        "Mimey",
        "mironova",
        "modificator",
        "Modificators",
        "nbproject",
        "NOSORT",
        "notext",
        "Numpad",
        "ospl",
        "plog",
        "Promocode",
        "qatest",
        "Recalc",
        "Redirector",
        "rutube",
        "saysimsim",
        "searchengiines",
        "sewa",
        "userfile",
        "vazovsky",
        "yamr",
        "автозаполнения",
        "коммитах",
        "логировать",
        "Модал",
        "Модала",
        "Модале",
        "Модалом",
        "регресионное",
        "Роут",
        "Спана",
        "третьесторонним",
        "Фандиста",
        "эндпоинт"
    ],
    // endregion SPELL
    // region EXCLUDE
    "files.exclude": {
        "**/.idea/": true,
        "**/.idea": true,
        "**/.project": true,
        "**/node_modules": true,
        "**/bower_components": true,
        "**/.git": true,
        "**/dist": false,
        "**/build": true,
        "**/__pycache__": true, // Example for Python
        "**/.venv": true, // Example for Python virtual environment
        "**/database": true,
        "ChangeLog": true
    },
    "search.exclude": {
        "**/.idea": true,
        "**/db": true,
        "**/.project": true,
        "**/node_modules": true,
        "**/bower_components": true,
        "**/.git": true,
        "**/dist": true,
        "**/dist-stage": true,
        "**/build": true,
        "**/__pycache__": true,
        "**/.venv": true,
        "**/database": true,
        "**/var/www/zero.home": true,
        "**/var/www/saysimsim.ru": true,
        "**/var/www/vov": true,
        "**/var/www/m45a": true,
        "**/var/www/stage": true,
        "**/var/log": true,
        "**/package-lock.json": true,
        "ChangeLog": true
    },
    // region EXCLUDE
    // "workbench.editor.enablePreview": false,
    "workbench.editor.revealIfOpen": true,
    "editor.overtypeOnPaste": false,
    // endregion CUSTOM
    // # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "[php]": {
        "editor.defaultFormatter": "DEVSENSE.phptools-vscode"
        // "editor.defaultFormatter": "kokororin.vscode-phpfmt"
        // "editor.defaultFormatter": "DEVSENSE.phptools-vscode"
    },
    "remote.SSH.remotePlatform": {
        "fundist.dev": "linux"
    },
    "workbench.colorTheme": "Better Material Theme Darker High Contrast",
    "[typescript]": {
        "editor.defaultFormatter": "vscode.typescript-language-features"
    },
    "editor.accessibilitySupport": "on",
    "window.newWindowDimensions": "maximized",
    "files.associations": {
        "*.blade.php": "php",
        "*.tpl": "php"
    },
    "security.workspace.trust.untrustedFiles": "open",
    "[javascript]": {
        // "editor.defaultFormatter": "vscode.typescript-language-features"
        // "editor.defaultFormatter": "vscode.typescript-language-features"
    },
    "[json]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "[html]": {
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
        // "editor.defaultFormatter": "vscode.html-language-features"
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "html.format.wrapAttributes": "preserve",
    "php.stubs": [
        "*",
        "Zookeeper",
    ],
    "editor.definitionLinkOpensInPeek": false,
    "bookmarks.saveBookmarksInProject": true,
    "search.showLineNumbers": true,
    "notebook.lineNumbers": "on",
    "search.defaultViewMode": "tree",
    "search.quickAccess.preserveInput": true,
    "search.searchEditor.defaultNumberOfContextLines": 3,
    "editor.colorDecoratorsActivatedOn": "click",
    "editor.colorDecoratorsLimit": 5000,
    "editor.defaultColorDecorators": "always",
    "[sql]": {
        "editor.defaultFormatter": "adpyke.vscode-sql-formatter"
    },
    "[dockercompose]": {
        "editor.insertSpaces": true,
        "editor.tabSize": 2,
        "editor.autoIndent": "advanced",
        "editor.quickSuggestions": {
            "other": true,
            "comments": false,
            "strings": true
        },
        "editor.defaultFormatter": "redhat.vscode-yaml"
    },
    "[github-actions-workflow]": {
        "editor.defaultFormatter": "redhat.vscode-yaml"
    },
    "git.blame.editorDecoration.enabled": true,
    "phpfmt.php_bin": "C:/_NGINX/_PHP8.2/php.exe",
    "phpfmt.enable_auto_align": true,
    "code-eol.highlightExtraWhitespace": true,
    "code-eol.colors.error.foreground": "#ff0000",
    "code-eol.colors.default.foreground": "#333333",
    "editor.renderWhitespace": "all",
    "alignmenthash.surroundSpace": {
        "colon": [
            -1,
            1
        ], // The first number specify how much space to add to the left, can be negative. // The second number is how much space to the right, can be negative.
        "assignment": [
            1,
            1
        ], // 1The same as above.
        "arrow": [
            1,
            -1
        ], // The same as above.
        "comment": 2 // Special how much space to add between the trailing comment and the code. // If this value is negative, it means don't align the trailing comment.
    },
    "phpfmt.passes": [
        "TrimSpaceBeforeSemicolon",
        "SpaceBetweenMethods",
        "SpaceAroundControlStructures",
        "AlignPHPCode",
        "SpaceAfterExclamationMark",
        "AlignConstVisibilityEquals",
        "AutoSemicolon",
        "AlignEquals",
        "MergeNamespaceWithOpenTag",
        "RemoveSemicolonAfterCurly",
        // "indent_with_space": 4,
        "RestoreComments",
        "ShortArray",
        "AlignDoubleSlashComments",
        "IndentTernaryConditions",
        "IndentPipeOperator",
        "AlignEquals",
        "AlignDoubleArrow",
        "AlignGroupDoubleArrow"
    ],
    "editor.gotoLocation.multipleDefinitions": "goto",
    "editor.allowVariableFontsInAccessibilityMode": true,
    "editor.inlineCompletionsAccessibilityVerbose": true,
    "editor.cursorStyle": "line",
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.cursorWidth": 4,
    "editor.folding": true,
    "editor.glyphMargin": true,
    "selection-foreground.textColor": "#000000",
    "selection-foreground.enabled": true,
    "editor.inlineSuggest.experimental.emptyResponseInformation": false,
    "application.experimental.rendererProfiling": true,
    "editor.accessibilityPageSize": 1,
    "gitTreeCompare.diffMode": "full",
    "[vue]": {
        // "editor.defaultFormatter": "esbenp.prettier-vscode"
        // "editor.defaultFormatter": "vscode.html-language-features"
        // "editor.defaultFormatter": "Vue.volar"
        // "editor.defaultFormatter": "cweijan.vetur-plus"
    },
    "eslint.codeActionsOnSave.options": {},
    "debug.javascript.resourceRequestOptions": {},
    "[css]": {
        "editor.defaultFormatter": "vscode.css-language-features"
    },
    "typescript.tsserver.maxTsServerMemory": 7000,
    "search.useIgnoreFiles": false,
    "sftp.printDebugLog": true,
    "sftp.debug": true,
    "editor.rulers": [
        1111
    ],
    "editor.wordWrapColumn": 500,
    "diffEditor.wordWrap": "off",
    "editor.wrappingIndent": "none",
    "code-eol.forceShowOnBoundary": true,
    "code-eol.forceShowOnWordWrap": true,
    "editor.comments.ignoreEmptyLines": false,
    "accessibility.verbosity.comments": false,
    "html.format.wrapLineLength": 500,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "notebook.defaultFormatter": "esbenp.prettier-vscode",
    "javascript.inlayHints.propertyDeclarationTypes.enabled": true,
    "[shellscript]": {
        // "editor.defaultFormatter": "lumirelle.shell-format-rev"
    },
    "docker.extension.enableComposeLanguageServer": false,
    "highlight.maxMatches": 5000,
    "gitlens.fileAnnotations.command": "blame",
    "gitlens.currentLine.uncommittedChangesFormat": "\"ASDF\"",
    "gitlens.currentLine.fontSize": 12,
    "vetur.format.scriptInitialIndent": true,
    "vetur.format.styleInitialIndent": true,
    "vetur.ignoreProjectWarning": true,
    "vetur.trace.server": "messages",
    "prettier.singleAttributePerLine": true,
    "editor.bracketPairColorization.independentColorPoolPerBracketType": true,
    "explorer.compactFolders": false,
    "editor.defaultFoldingRangeProvider": "esbenp.prettier-vscode",
    "vetur.experimental.templateInterpolationService": true,
    "vetur.validation.templateProps": true,
    "vetur.completion.tagCasing": "initial",
    "workbench.editor.enablePreview": false,
    "scm.diffDecorationsIgnoreTrimWhitespace": "true",
    "gitlens.blame.ignoreWhitespace": true,
    "[xml]": {
        "editor.defaultFormatter": "redhat.vscode-xml"
    },
    "markdown-pdf.breaks": true,
    "markdown-pdf.highlightStyle": "a11y-dark.css",
    "editor.scrollBeyondLastLine": false,
    "editor.fastScrollSensitivity": 1,
    "php.inlayHints.parameters.enabled": false,
    "bookmarks.sideBar.expanded": true,
    "trailing-spaces.deleteModifiedLinesOnly": true,
    "trailing-spaces.logLevel": "error",
    "[dockerfile]": {
        "editor.defaultFormatter": "ms-azuretools.vscode-containers"
    },
    "window.customMenuBarAltFocus": false,
    "window.enableMenuBarMnemonics": false,
    "files.trimTrailingWhitespaceInRegexAndStrings": false,
    "trailing-spaces.trimOnSave": true,
    "chat.disableAIFeatures": true,
    "editor.renderRichScreenReaderContent": true,
}