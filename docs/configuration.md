# Configuration Options

This document outlines the various configuration options available in the Windows System Update Script.

## Core Configuration Variables

These variables are defined at the beginning of the script and can be modified to customize behavior:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `$logDirectory` | `$env:USERPROFILE\Logs` | Directory where log files are saved |
| `$logFile` | `$logDirectory\SystemUpdate_[timestamp].log` | Complete path to the log file |
| `$ErrorActionPreference` | `Stop` | PowerShell error action preference |

## Customizing Log Location

To change where logs are stored, modify the `$logDirectory` variable:

```powershell
# Default location
$logDirectory = Join-Path -Path $env:USERPROFILE -ChildPath "Logs"

# Example custom location
$logDirectory = "C:\SystemLogs"
```

## Customizing Error Handling

The script uses PowerShell's error handling system. To modify how errors are handled, change the `$ErrorActionPreference` variable:

```powershell
# Default - Stop script execution on errors
$ErrorActionPreference = 'Stop'

# Alternative - Continue script execution on errors
$ErrorActionPreference = 'Continue'

# Alternative - Show error but don't stop (useful for less critical sections)
$ErrorActionPreference = 'SilentlyContinue'
```

## Disabling Specific Update Mechanisms

If you want to disable specific update mechanisms, you can comment out or remove the relevant sections:

### To Disable Winget Updates

Comment out the Winget update section:

```powershell
# Step 1: Update with Winget
<# 
try {
    if (Test-CommandExists -Command "winget") {
        Write-Log -Message "Updating applications using winget..." -Level 'Info'
        ...
    }
} catch {
    ...
}
#>
```

### To Disable Chocolatey Updates

Comment out the Chocolatey update section:

```powershell
# Step 2: Update with Chocolatey
<#
try {
    if (Test-CommandExists -Command "choco") {
        Write-Log -Message "Updating packages using Chocolatey..." -Level 'Info'
        ...
    }
} catch {
    ...
}
#>
```

### To Disable Windows Updates

Comment out the Windows Update section:

```powershell
# Step 3: Windows Updates
<#
try {
    # Check if PSWindowsUpdate module is installed
    ...
} catch {
    ...
}
#>
```

## Adding Additional Update Mechanisms

To add a new update mechanism, follow this template:

```powershell
# Step X: Update with [New Mechanism]
try {
    if (Test-CommandExists -Command "[command]") {
        Write-Log -Message "Updating using [New Mechanism]..." -Level 'Info'
        & [command] [parameters] | Tee-Object -Variable outputVariable
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message "[New Mechanism] update completed successfully" -Level 'Success'
            $updateSummary.NewMechanism = "Success"
        } else {
            Write-Log -Message "[New Mechanism] update completed with exit code: $LASTEXITCODE" -Level 'Warning'
            $updateSummary.NewMechanism = "Warning (Exit code: $LASTEXITCODE)"
        }
    } else {
        Write-Log -Message "[New Mechanism] is not installed on this system" -Level 'Warning'
        $updateSummary.NewMechanism = "Not Installed"
    }
} catch {
    Write-Log -Message "Error updating with [New Mechanism]: $_" -Level 'Error'
    $updateSummary.NewMechanism = "Error: $_"
}
```

Don't forget to add the new mechanism to the `$updateSummary` hashtable at the beginning of the script:

```powershell
$updateSummary = @{
    Winget = "Not Run"
    Chocolatey = "Not Run"
    WindowsUpdate = "Not Run"
    NewMechanism = "Not Run"  # Add this line
    StartTime = Get-Date
    EndTime = $null
}
```

