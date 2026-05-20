function toggleDolphin() {
    console.log('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
    var process = new KProcess();
    process.setShellCommand("dolphin");
    process.start();
}

registerShortcut(
  "sewadolphinoneapp",
  "Sewa Dolphin One App",
  "Meta+E",у
  toggleDolphin
);