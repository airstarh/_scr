// cursor_tracker.js
// Register a global shortcut (e.g., Meta+C) to trigger the action
registerShortcut(
  "Move Mouse to Cursor",
  "Move mouse to text cursor position",
  "Ctrl+F1",
  function () {
    console.log("");
    console.log("");
    console.log("AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA ");
    // 1. Get the currently focused client (window)
    var client = workspace.activeClient;

    if (!client) {
      print("No active window");
      return;
    }

    // 2. Request the text cursor position from the focused surface
    // Note: This uses the internal Wayland text_input protocol.
    // The actual position is stored in the 'cursorRectangle' property of the text input.
    try {
      // This is a simplified representation.
      // A real implementation requires deeper DBus or C++ integration.
      var textInput = client.textInput;

      if (textInput && textInput.cursorRectangle) {
        var rect = textInput.cursorRectangle;

        // Calculate center of the cursor
        var targetX = rect.x + rect.width / 2;
        var targetY = rect.y + rect.height / 2;

        // 3. Send the coordinates to be caught by the shell script
        // We use DBus to signal an external script
        var service = "org.kde.KWin";
        var path = "/CursorTracker";
        // This sends the coordinates to a DBus interface we will listen to
        callDBus(service, path, "local.MoveCursor", "move", targetX, targetY);
      } else {
        print("No text input focused or cursor rectangle unavailable.");
      }
    } catch (e) {
      print("Error: " + e);
    }
  },
);

// Helper to print to console (visible in `journalctl` or KWin console)
function print(message) {
  print("sewa: " + message);
}
