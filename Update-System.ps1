<#
.SYNOPSIS
    System-wide update script for Windows.

.DESCRIPTION
    This script performs system-wide updates using winget, Chocolatey, and Windows Update.
    It requires administrative privileges to run properly.

.NOTES
    File Name      : Update-System.ps1
    Author         : System Administrator
    Prerequisite   : PowerShell 7+, Administrative privileges
    Version        : 1.0
    Created        : 2025-05-19
#>

#Requires -RunAsAdministrator
#Requires -Version 7.0

# Set strict mode and error action
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Script variables
$logDirectory = Join-Path -Path $env:USERPROFILE -ChildPath "Logs"
$logFile = Join-Path -Path $logDirectory -ChildPath "SystemUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$updateSummary = @{
    Winget = "Not Run"
    Chocolatey = "Not Run"
    WindowsUpdate = "Not Run"
    StartTime = Get-Date
    EndTime = $null
}

# Function to write to log file and console
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    # Create timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Format message based on level
    switch ($Level) {
        'Info'    { $formattedMessage = "[$timestamp] [INFO] $Message"; Write-Host $formattedMessage -ForegroundColor Cyan }
        'Warning' { $formattedMessage = "[$timestamp] [WARNING] $Message"; Write-Host $formattedMessage -ForegroundColor Yellow }
        'Error'   { $formattedMessage = "[$timestamp] [ERROR] $Message"; Write-Host $formattedMessage -ForegroundColor Red }
        'Success' { $formattedMessage = "[$timestamp] [SUCCESS] $Message"; Write-Host $formattedMessage -ForegroundColor Green }
    }
    
    # Create log directory if it doesn't exist
    if (-not (Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $logFile -Value $formattedMessage
}

# Function to check if a command exists
function Test-CommandExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Start script execution
Write-Log -Message "Starting system update process" -Level 'Info'
Write-Log -Message "Log file: $logFile" -Level 'Info'

# Step 1: Update with Winget
try {
    if (Test-CommandExists -Command "winget") {
        Write-Log -Message "Updating applications using winget..." -Level 'Info'
        & winget upgrade --all --accept-source-agreements | Tee-Object -Variable wingetOutput
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message "Winget update completed successfully" -Level 'Success'
            $updateSummary.Winget = "Success"
        } else {
            Write-Log -Message "Winget update completed with exit code: $LASTEXITCODE" -Level 'Warning'
            $updateSummary.Winget = "Warning (Exit code: $LASTEXITCODE)"
        }
    } else {
        Write-Log -Message "Winget is not installed on this system" -Level 'Warning'
        $updateSummary.Winget = "Not Installed"
    }
} catch {
    Write-Log -Message "Error updating with winget: $_" -Level 'Error'
    $updateSummary.Winget = "Error: $_"
}

# Step 2: Update with Chocolatey
try {
    if (Test-CommandExists -Command "choco") {
        Write-Log -Message "Updating packages using Chocolatey..." -Level 'Info'
        & choco upgrade all -y | Tee-Object -Variable chocoOutput
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message "Chocolatey update completed successfully" -Level 'Success'
            $updateSummary.Chocolatey = "Success"
        } else {
            Write-Log -Message "Chocolatey update completed with exit code: $LASTEXITCODE" -Level 'Warning'
            $updateSummary.Chocolatey = "Warning (Exit code: $LASTEXITCODE)"
        }
    } else {
        Write-Log -Message "Chocolatey is not installed on this system" -Level 'Warning'
        $updateSummary.Chocolatey = "Not Installed"
    }
} catch {
    Write-Log -Message "Error updating with Chocolatey: $_" -Level 'Error'
    $updateSummary.Chocolatey = "Error: $_"
}

# Step 3: Windows Updates
try {
    # Check if PSWindowsUpdate module is installed
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Log -Message "PSWindowsUpdate module not found. Attempting to install..." -Level 'Info'
        
        try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
            Write-Log -Message "PSWindowsUpdate module installed successfully" -Level 'Success'
        } catch {
            Write-Log -Message "Failed to install PSWindowsUpdate module: $_" -Level 'Error'
            throw "Unable to install PSWindowsUpdate module"
        }
    }
    
    # Import the module
    Import-Module PSWindowsUpdate
    
    # Check for Windows updates
    Write-Log -Message "Checking for Windows updates..." -Level 'Info'
    $availableUpdates = Get-WindowsUpdate 
    
    if ($availableUpdates.Count -gt 0) {
        Write-Log -Message "Found $($availableUpdates.Count) Windows updates available" -Level 'Info'
        
        # Prompt user for confirmation to install updates
        $confirmation = Read-Host "Do you want to install Windows updates? (Y/N)"
        
        if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
            Write-Log -Message "Installing Windows updates..." -Level 'Info'
            Install-WindowsUpdate -AcceptAll -AutoReboot | Tee-Object -Variable windowsUpdateOutput
            Write-Log -Message "Windows Update completed successfully" -Level 'Success'
            $updateSummary.WindowsUpdate = "Success"
        } else {
            Write-Log -Message "Windows Update installation skipped by user" -Level 'Info'
            $updateSummary.WindowsUpdate = "Skipped by user"
        }
    } else {
        Write-Log -Message "No Windows updates available" -Level 'Info'
        $updateSummary.WindowsUpdate = "No updates available"
    }
} catch {
    Write-Log -Message "Error processing Windows Updates: $_" -Level 'Error'
    $updateSummary.WindowsUpdate = "Error: $_"
}

# Complete and summarize
$updateSummary.EndTime = Get-Date
$duration = $updateSummary.EndTime - $updateSummary.StartTime

Write-Log -Message "System update process completed" -Level 'Info'
Write-Log -Message "Total duration: $($duration.ToString('hh\:mm\:ss'))" -Level 'Info'
Write-Log -Message "Update Summary:" -Level 'Info'
Write-Log -Message "  Winget: $($updateSummary.Winget)" -Level 'Info'
Write-Log -Message "  Chocolatey: $($updateSummary.Chocolatey)" -Level 'Info'
Write-Log -Message "  Windows Update: $($updateSummary.WindowsUpdate)" -Level 'Info'

Write-Host "`nUpdate process completed. See log file for details: $logFile" -ForegroundColor Green

