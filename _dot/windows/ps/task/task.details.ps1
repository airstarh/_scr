# Для Installation
Get-ScheduledTask -TaskPath "\Microsoft\Windows\LanguageComponentsInstaller\" -TaskName "Installation" |
    Export-ScheduledTask

# Для Backup
Get-ScheduledTask -TaskPath "\Microsoft\Windows\AppListBackup\" -TaskName "Backup" |
    Export-ScheduledTask
