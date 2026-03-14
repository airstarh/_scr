Get-ScheduledTask -TaskPath "\Microsoft\Windows\LanguageComponentsInstaller\" -TaskName "Installation" |
    Select-Object -ExpandProperty Actions |
    Format-List *