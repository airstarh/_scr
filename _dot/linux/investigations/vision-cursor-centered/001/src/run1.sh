SCRIPT=$(qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript ./get_mouse.js)
qdbus org.kde.KWin /Scripting/Script${SCRIPT} org.kde.kwin.Script.run
qdbus org.kde.KWin /Scripting/Script${SCRIPT} org.kde.kwin.Script.stop
