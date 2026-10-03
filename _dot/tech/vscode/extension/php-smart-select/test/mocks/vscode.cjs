const state = { providers: [], warnings: [], infos: [], config: {} };

class Position {
  constructor(line, character) { this.line = line; this.character = character; }
  isBefore(other) { return this.line < other.line || (this.line === other.line && this.character < other.character); }
  isEqual(other) { return this.line === other.line && this.character === other.character; }
}

class Range {
  constructor(start, end) { this.start = start; this.end = end; }
}

class SelectionRange {
  constructor(range, parent) { this.range = range; this.parent = parent; }
}

module.exports = {
  __state: state,
  Position,
  Range,
  SelectionRange,
  workspace: {
    getConfiguration() {
      return { get(key, fallback) { return key in state.config ? state.config[key] : fallback; } };
    },
    onDidChangeTextDocument() { return { dispose() {} }; },
    onDidCloseTextDocument() { return { dispose() {} }; },
    onDidChangeConfiguration() { return { dispose() {} }; },
  },
  languages: {
    registerSelectionRangeProvider(selector, provider) {
      state.providers.push({ selector, provider });
      return { dispose() {} };
    },
  },
  window: {
    showWarningMessage(message) { state.warnings.push(String(message)); },
    showInformationMessage(message) { state.infos.push(String(message)); return Promise.resolve(undefined); },
  },
  commands: { executeCommand() {} },
};
