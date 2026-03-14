Get-ScheduledTask | ForEach-Object {
    $taskInfo = $_ | Get-ScheduledTaskInfo
    [PSCustomObject]@{
        TaskName = $_.TaskName
        TaskPath = $_.TaskPath
        State = $_.State
        CreationTime = $taskInfo.CreationTime
        LastRunTime = $taskInfo.LastRunTime
        NextRunTime = $taskInfo.NextRunTime
    }
} | Sort-Object CreationTime -Descending | Select-Object -First 10
