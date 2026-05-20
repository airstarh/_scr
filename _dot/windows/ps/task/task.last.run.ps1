Get-ScheduledTask | ForEach-Object {
    $taskInfo = $_ | Get-ScheduledTaskInfo
    [PSCustomObject]@{
        TaskName = $_.TaskName
        TaskPath = $_.TaskPath
        LastRunTime = $taskInfo.LastRunTime
        Command = ($_.Actions.Execute -join "; ")
    }
} | Sort-Object LastRunTime -Descending | Select-Object -First 11 | Format-Table -AutoSize

# TASK DETAILS BY NAME:
# Get-ScheduledTask -TaskName "USER_ESRV_SVC_QUEENCREEK" | Select-Object *