# Setting Up Scheduled Tasks for Windows System Scripts

This guide explains how to set up scheduled tasks to automate both the Update-System.ps1 and Install-DevTools.ps1 scripts. Automating these scripts ensures your system stays up-to-date with minimal manual intervention.

## Table of Contents

- [General Scheduled Task Setup](#general-scheduled-task-setup)
  - [Using Task Scheduler GUI](#using-task-scheduler-gui)
  - [Using PowerShell Commands](#using-powershell-commands)
- [Script-Specific Configurations](#script-specific-configurations)
  - [Update-System.ps1 Scheduling](#update-systemps1-scheduling)
  - [Install-DevTools.ps1 Scheduling](#install-devtoolsps1-scheduling)
- [Scheduling Scenarios](#scheduling-scenarios)
  - [Daily Updates](#daily-updates)
  - [Weekly Updates](#weekly-updates)
  - [Monthly Updates](#monthly-updates)
- [Error Handling and Logging](#error-handling-and-logging)
- [Task Triggers and Conditions](#task-triggers-and-conditions)
- [Troubleshooting](#troubleshooting)

## General Scheduled Task Setup

### Using Task Scheduler GUI

1. Open Task Scheduler (search for "Task Scheduler" in the Start menu)
2. Click "Create Basic Task..." in the right-hand Actions panel
3. Enter a name (e.g., "Weekly System Update") and description
4. Choose a trigger (e.g., Weekly)
5. Configure the day and time for the task to run
6. Select "Start a program" for the action
7. For the program/script, enter:
   ```
   powershell.exe
   ```
8. For arguments, enter:
   ```
   -ExecutionPolicy Bypass -File "C:\path\to\script.ps1" [additional parameters]
   ```
   (Replace with the actual path to your script and any needed parameters)
9. Check "Open the Properties dialog for this task when I click Finish"
10. Click Finish
11. In the Properties dialog, check "Run with highest privileges"
12. On the Settings tab, consider enabling:
    - "Run task as soon as possible after a scheduled start is missed"
    - "If the task fails, restart every: [time period]"
13. Click OK to save the task

### Using PowerShell Commands

PowerShell provides a more programmatic way to create scheduled tasks:

```powershell
# Basic syntax for creating a scheduled task
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\path\to\script.ps1"'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3AM"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask -TaskName "Task Name" -InputObject $task
```

## Script-Specific Configurations

### Update-System.ps1 Scheduling

The system update script should be scheduled to run regularly to keep your system up-to-date.

#### GUI Configuration (Additional Arguments)

```
-ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"
```

#### PowerShell Command Example

```powershell
# Create a weekly system update task
$updateAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"'
$updateTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3AM"
$updatePrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$updateSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 5)
$updateTask = New-ScheduledTask -Action $updateAction -Principal $updatePrincipal -Trigger $updateTrigger -Settings $updateSettings
Register-ScheduledTask -TaskName "Weekly System Update" -InputObject $updateTask
```

### Install-DevTools.ps1 Scheduling

The Install-DevTools script should be configured to run in non-interactive mode with specific parameters.

#### GUI Configuration (Additional Arguments)

```
-ExecutionPolicy Bypass -File "C:\path\to\Install-DevTools.ps1" -NonInteractive -AllCategories
```

Or for specific categories:

```
-ExecutionPolicy Bypass -File "C:\path\to\Install-DevTools.ps1" -NonInteractive -DevTools -SupportingTools
```

#### PowerShell Command Example

```powershell
# Create a monthly software installation task for development tools
$installAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\path\to\Install-DevTools.ps1" -NonInteractive -DevTools'
$installTrigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At "4AM"
$installPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$installSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$installTask = New-ScheduledTask -Action $installAction -Principal $installPrincipal -Trigger $installTrigger -Settings $installSettings
Register-ScheduledTask -TaskName "Monthly Dev Tools Update" -InputObject $installTask
```

## Scheduling Scenarios

### Daily Updates

Good for critical production environments or development machines that need to stay current:

```powershell
# Daily system updates at 10PM
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At "10PM"
```

**Use case**: Developer workstations, security-critical systems

### Weekly Updates

Recommended for most users - balances staying current with stability:

```powershell
# Weekly system updates on Sunday at 3AM
$weeklyTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3AM"
```

**Use case**: Personal computers, general workstations

### Monthly Updates

Best for stable systems where frequent changes are not desired:

```powershell
# Monthly system updates on the first day of each month at 4AM
$monthlyTrigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At "4AM"
```

**Use case**: Production servers, specialized workstations

## Error Handling and Logging

Both scripts include built-in logging, but you can enhance error handling through task settings:

```powershell
# Create task settings with retry logic
$retrySettings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -DontStopOnIdleEnd `
    -RestartCount 3 `                     # Retry up to 3 times
    -RestartInterval (New-TimeSpan -Minutes 5) ` # Wait 5 minutes between retries
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)   # Maximum run time of 2 hours
```

You can also set up email notifications for task failures:

```powershell
# Send email notification on task failure
$emailAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -Command "Send-MailMessage -To admin@example.com -From system@example.com -Subject \"Task Failed\" -Body \"The scheduled system update task failed.\" -SmtpServer smtp.example.com"'
$failTrigger = New-ScheduledTaskTrigger -OnTaskFailure
```

## Task Triggers and Conditions

### Additional Trigger Examples

```powershell
# Run at system startup with a 15-minute delay
$startupTrigger = New-ScheduledTaskTrigger -AtStartup
$startupTrigger.Delay = 'PT15M'  # 15-minute delay

# Run when a user logs on
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn

# Run on idle
$idleTrigger = New-ScheduledTaskTrigger -AtIdle -IdleDuration 00:10:00
```

### Optimal Conditions

Configure task conditions to run only under optimal circumstances:

```powershell
# Create task settings that only run when conditions are ideal
$conditionalSettings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `                      # Run if start time is missed
    -RunOnlyIfNetworkAvailable `               # Only run with network connection
    -WakeToRun `                               # Wake computer to run task
    -RunOnlyIfIdle `                           # Only run when computer is idle
    -IdleDuration (New-TimeSpan -Minutes 10) ` # Computer must be idle for 10 minutes
    -IdleWaitTimeout (New-TimeSpan -Hours 1)   # Wait up to 1 hour for idle
```

## Combining Multiple Scripts

You can set up a master script that runs both update and installation tasks:

```powershell
# Create a master script (MasterUpdate.ps1)
$masterScript = @'
# Run system updates
& "$PSScriptRoot\Update-System.ps1"

# Check exit code and proceed only if updates were successful
if ($LASTEXITCODE -eq 0) {
    # Run software installations
    & "$PSScriptRoot\Install-DevTools.ps1" -NonInteractive -DevTools -SupportingTools
}

# Log completion
$logFile = Join-Path -Path $env:USERPROFILE -ChildPath "Logs\MasterUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
"$(Get-Date) - Master update script completed with exit code: $LASTEXITCODE" | Out-File -FilePath $logFile -Append
'@

# Save the master script
$masterScript | Out-File -FilePath "C:\path\to\MasterUpdate.ps1"

# Create a task for the master script
$masterAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\path\to\MasterUpdate.ps1"'
$masterTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3AM"
$masterPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$masterSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$masterTask = New-ScheduledTask -Action $masterAction -Principal $masterPrincipal -Trigger $masterTrigger -Settings $masterSettings
Register-ScheduledTask -TaskName "Weekly Master System Update" -InputObject $masterTask
```

## Troubleshooting

If your scheduled tasks don't run properly:

1. **Check task history**: Open Task Scheduler, select your task, and click on the "History" tab to view the task's execution history.

2. **Verify permissions**:
   - Ensure the task is set to "Run with highest privileges"
   - Make sure the user account has administrative privileges

3. **Test the script manually**:
   - Run the script manually with the same parameters to verify it works
   - Look for error messages or unexpected behavior

4. **Check log files**:
   - Both scripts create detailed log files in `%USERPROFILE%\Logs`
   - Examine these logs for error messages or warnings

5. **Execution policy issues**:
   - Make sure the command includes `-ExecutionPolicy Bypass`
   - If still having issues, try setting the execution policy system-wide:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
     ```

6. **Task scheduler service**:
   - Ensure the Task Scheduler service is running:
     ```powershell
     Get-Service -Name Schedule | Select-Object Status
     ```
   - If it's not running, start it:
     ```powershell
     Start-Service -Name Schedule
     ```

7. **Path issues**:
   - Use absolute paths in your task configuration
   - Avoid network paths unless necessary (and ensure proper credentials)

