// Save as: ~/.local/share/kwin/scripts/cursor_tracker/contents/code/main.js

registerShortcut(
  "Move Mouse to Cursor",
  "Move mouse to text cursor",
  "Ctrl+F1",
  function () {
    // Since we CAN'T get text cursor position directly,
    // we'll use KWin's cursor position as a placeholder
    // and signal the bash script to read from accessibility
    var currentPos = workspace.cursorPos;

    // Send DBus signal to bash script
    callDBus(
      "local.CursorTracker", // service
      "/CursorTracker", // path
      "local.CursorTracker", // interface
      "MoveRequest", // method
      currentPos.x, // arg1 - current mouse X (placeholder)
      currentPos.y, // arg2 - current mouse Y (placeholder)
    );

    print("Signal sent to move mouse to text cursor");
  },
);

function print(message) {
  print("CursorTracker: " + message);
}
