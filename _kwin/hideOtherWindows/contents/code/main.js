function hideOtherWindows() {
  const activeWindow = workspace.activeWindow; // Renamed from activeClient
  if (!activeWindow) return; // Safety check: if no window is focused

  const windows = workspace.windowList(); // Renamed from clientList
  windows.forEach(function (win) {
    // Check if it's not the active one, it's a normal window, and not already minimized
    if (win !== activeWindow && win.normalWindow && !win.minimized) {
      win.minimized = true; // You can also use win.minimize()
    }
  });
}

registerShortcut(
  "Hide Other Windows",
  "Minimizes all windows except active one",
  "Meta+H", // Note: "Super" is usually written as "Meta" in KDE
  hideOtherWindows,
);
