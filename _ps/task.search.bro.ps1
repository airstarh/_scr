### Search Task by Name, Description, Command
$searchTerm = "yandex"
$matchingTasks = @()

Get-ScheduledTask | ForEach-Object {
    $task = $_
    $nameMatch = $task.TaskName -like "*$searchTerm*"
    $descriptionMatch = $false
    $commandMatch = $false

    # Check description (if available)
    if ($task.Description) {
        $descriptionMatch = $task.Description -like "*$searchTerm*"
    }

    # Check command/action
    $task.Actions | ForEach-Object {
        if ($_.Execute -like "*$searchTerm*" -or $_.Arguments -like "*$searchTerm*") {
            $commandMatch = $true
        }
    }

    if ($nameMatch -or $descriptionMatch -or $commandMatch) {
        $matchingTasks += $task
    }
}

# Output results
$matchingTasks | Select-Object TaskName, TaskPath, State, Description, @{
    Name = "Command";
    Expression = { ($_.Actions.Execute -join "; ") }
}, @{
    Name = "Arguments";
    Expression = { ($_.Actions.Arguments -join "; ") }
} | Format-Table -AutoSize
