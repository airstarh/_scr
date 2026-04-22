function hideOtherWindows() {
  const activeWindow = workspace.activeClient;
  workspace.clientList().forEach(function (win) {
    if (win !== activeWindow && win.normalWindow && !win.minimized) {
      win.minimize();
    }
  });
}

registerShortcut(
  "Hide Other Windows", // Название действия
  "Minimizes all windows except active one", // Описание
  "Super+H", // Горячая клавиша
  hideOtherWindows, // Функция для вызова
);
