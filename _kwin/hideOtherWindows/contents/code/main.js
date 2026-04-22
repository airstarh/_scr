/**
kpackagetool6 --type KWin/Script --install .

dbus-send --print-reply --dest=org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript string:"hide-other-windows"
dbus-send --print-reply --dest=org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript string:"hide-other-windows"
 *
 *
 * @param {*} title
 * @param {*} message
 */
function notify(title, message) {
  callDBus(
    "org.freedesktop.Notifications",
    "/org/freedesktop/Notifications",
    "org.freedesktop.Notifications",
    "Notify",
    "KWin Script", // App name
    0, // ID to replace
    "kwin", // Icon name (VS Code's linter might mark "kwin" as unknown word, but it's typically fine)
    title, // Summary
    message, // Body
    [],
    {}, // Actions and hints
    3000, // Timeout in milliseconds (3 seconds)
  );
}

function hideOtherWindows() {
  // Show the alert immediately so we know the shortcut triggered
  notify("KWin Script", "Hiding other windows...");

  const activeWindow = workspace.activeWindow;

  if (!activeWindow) {
    notify("KWin Script", "No active window found!");
    return;
  }

  const windows = workspace.windowList();
  windows.forEach(function (win) {
    // Condition: Not the active window, is a normal window, and is not already minimized
    if (win !== activeWindow && win.normalWindow && !win.minimized) {
      win.minimized = true;
    }
  });
}

// Registering the shortcut
registerShortcut(
  "hide-other-windows", // <-- Changed to match metadata.json ID, and removed _id suffix
  "Hide Other Windows Script",
  "Meta+H",
  hideOtherWindows
);
