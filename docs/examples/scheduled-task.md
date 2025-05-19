# Setting Up a Scheduled Task

This guide explains how to set up a scheduled task to run the Windows System Update Script automatically.

## Using Task Scheduler GUI

1. Open Task Scheduler (search for "Task Scheduler" in the Start menu)
2. Click "Create Basic Task..." in the right-hand Actions panel
3. Enter a name (e.g., "Weekly System Update") and description
4. Choose a trigger (e.g., Weekly)
5. Configure the day and time for the update to run
6. Select "Start a program" for the action
7. For the program/script, enter:
   ```
   powershell.exe
   ```
8. For arguments, enter:
   ```
   -ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"
   ```
   (Replace with the actual path to your script)
9. Check "Open the Properties dialog for this task when I click Finish"
10. Click Finish
11. In the Properties dialog, check "Run with highest privileges"
12. Configure any additional settings as needed
13. Click OK

## Using PowerShell

You can also create a scheduled task using PowerShell:

```powershell
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3AM"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask -TaskName "Weekly System Update" -InputObject $task
```

## Recommended Schedule

For most users, we recommend:

- Weekly updates (e.g., every Sunday)
- During off-hours (e.g., 3:00 AM)
- With "Run with highest privileges" enabled
- With "Run whether user is logged on or not" enabled

## Verifying the Task

After setting up the scheduled task:

1. Right-click on your task and select "Run" to test it
2. Check the log file (in `%USERPROFILE%\Logs`) to verify it ran correctly
3. Review the task's history in Task Scheduler to see if it executed successfully

## Troubleshooting

If the scheduled task doesn't run properly:

1. Check that

