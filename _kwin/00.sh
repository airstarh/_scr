kpackagetool6 --type KWin/Script --uninstall hide-other-windows
kpackagetool6 --type KWin/Script --install .
kpackagetool6 --type KWin/Script --upgrade .

journalctl -f | grep kwin_wayland
journalctl -f --user-unit plasma-kwin_wayland

dbus-send --print-reply --dest=org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript string:"hideotherwindowssewa"
dbus-send --print-reply --dest=org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript string:"hideotherwindowssewa"