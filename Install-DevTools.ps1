<#
.SYNOPSIS
    Installation script for development, FPGA, gaming/emulation, and ROM management tools.

.DESCRIPTION
    This script provides functions to install software packages for various specialized uses
    including software development, FPGA development, gaming emulation, and ROM management.
    It supports installation via winget and chocolatey package managers.

.NOTES
    File Name      : Install-DevTools.ps1
    Author         : System Administrator
    Prerequisite   : PowerShell 7+, Administrative privileges, winget and/or chocolatey
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
$logFile = Join-Path -Path $logDirectory -ChildPath "DevTools_Installation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$installationSummary = @{
    Succeeded = @()
    Failed = @()
    Skipped = @()
    StartTime = Get-Date
    EndTime = $null
}

# Define package lists for different categories
$developmentTools = @(
    @{ Name = "Microsoft.VisualStudioCode"; Source = "winget"; Description = "Visual Studio Code editor" },
    @{ Name = "Microsoft.WindowsTerminal"; Source = "winget"; Description = "Modern terminal application" },
    @{ Name = "Git.Git"; Source = "winget"; Description = "Distributed version control system" },
    @{ Name = "Python.Python.3"; Source = "winget"; Description = "Python programming language" },
    @{ Name = "OpenJS.NodeJS"; Source = "winget"; Description = "JavaScript runtime" },
    @{ Name = "Microsoft.DotNet.SDK.7"; Source = "winget"; Description = ".NET SDK" },
    @{ Name = "Microsoft.VisualStudio.2022.Community"; Source = "winget"; Description = "Visual Studio IDE" },
    @{ Name = "JetBrains.IntelliJIDEA.Community"; Source = "winget"; Description = "IntelliJ IDEA Community" },
    @{ Name = "Docker.DockerDesktop"; Source = "winget"; Description = "Docker Desktop" },
    @{ Name = "Microsoft.PowerShell"; Source = "winget"; Description = "PowerShell 7+" },
    @{ Name = "vscode-powershell"; Source = "choco"; Description = "PowerShell extension for VS Code" },
    @{ Name = "postman"; Source = "choco"; Description = "API Development Environment" }
)

$fpgaTools = @(
    @{ Name = "xilinx.vivado"; Source = "winget"; Description = "Xilinx Vivado Design Suite" },
    @{ Name = "intel.quartus-lite"; Source = "winget"; Description = "Intel Quartus Prime Lite" },
    @{ Name = "intel.modelsim"; Source = "winget"; Description = "ModelSim-Intel FPGA Starter Edition" },
    @{ Name = "nextpnr"; Source = "choco"; Description = "FPGA place-and-route tool" },
    @{ Name = "yosys"; Source = "choco"; Description = "Open source RTL synthesis tool" },
    @{ Name = "icestorm"; Source = "choco"; Description = "FPGA tools for Lattice iCE40" },
    @{ Name = "verilator"; Source = "choco"; Description = "Fast Verilog/SystemVerilog simulator" },
    
    # MiSTer FPGA tools and utilities
    @{ Name = "mister-devel.update_all"; Source = "choco"; Description = "MiSTer FPGA comprehensive update script" },
    @{ Name = "mister-devel.mister_offline"; Source = "choco"; Description = "MiSTer Offline Update utility" },
    @{ Name = "mister-tools"; Source = "choco"; Description = "MiSTer configuration and management tools" }
)

# Add a dedicated MiSTer tools category for more specialized tools
$misterTools = @(
    @{ Name = "MiSTer.MiSTerConfigurator"; Source = "winget"; Description = "MiSTer configuration GUI tool" },
    @{ Name = "mister-ini-editor"; Source = "choco"; Description = "Editor for MiSTer INI configuration files" },
    @{ Name = "mister-batch-control"; Source = "choco"; Description = "Batch control and management for MiSTer FPGA" }
)

$gamingEmulationTools = @(
    @{ Name = "Libretro.RetroArch"; Source = "winget"; Description = "Frontend for emulators, game engines" },
    @{ Name = "Dolphin.Dolphin"; Source = "winget"; Description = "GameCube/Wii emulator" },
    @{ Name = "PCSX2.PCSX2"; Source = "winget"; Description = "PlayStation 2 emulator" },
    @{ Name = "RPCS3.RPCS3"; Source = "winget"; Description = "PlayStation 3 emulator" },
    @{ Name = "citra-emu"; Source = "choco"; Description = "Nintendo 3DS emulator" },
    @{ Name = "ppsspp"; Source = "choco"; Description = "PSP emulator" },
    @{ Name = "desmume"; Source = "choco"; Description = "Nintendo DS emulator" },
    @{ Name = "mame"; Source = "choco"; Description = "Multiple Arcade Machine Emulator" },
    @{ Name = "yuzu"; Source = "choco"; Description = "Nintendo Switch emulator" }
)

$romManagementTools = @(
    @{ Name = "LaunchBox.LaunchBox"; Source = "winget"; Description = "Game library manager and launcher" },
    @{ Name = "romcenter"; Source = "choco"; Description = "ROM management and verification" },
    @{ Name = "clrmamepro"; Source = "choco"; Description = "ROM manager and verification tool" },
    @{ Name = "JRiver.MediaCenter"; Source = "winget"; Description = "Media library management" },
    
    # ROM and system management additions
    @{ Name = "Rufus.Rufus"; Source = "winget"; Description = "Bootable USB creator tool" },
    @{ Name = "mame-tools"; Source = "choco"; Description = "Tools for MAME ROM management" },
    @{ Name = "sabretools"; Source = "choco"; Description = "Tools for ROM identification and management" },
    @{ Name = "romvault"; Source = "choco"; Description = "ROM collection management and verification" },
    
    # 1G1R (One Game, One ROM) tools
    @{ Name = "1g1r"; Source = "choco"; Description = "One Game One ROM set management tools" }
)

# Create a new category for handheld device management tools
$handheldDeviceTools = @(
    @{ Name = "AnalogueOS.PocketUpdater"; Source = "winget"; Description = "Firmware updater for Analogue Pocket console" },
    @{ Name = "AnalogueOS.PocketSync"; Source = "winget"; Description = "Sync tool for Analogue Pocket console" },
    
    # MiSTer can also be considered a handheld/portable device in some configurations
    @{ Name = "mister-wifi-config"; Source = "choco"; Description = "WiFi configuration tool for MiSTer FPGA portables" }
)

$supportingTools = @(
    @{ Name = "7zip.7zip"; Source = "winget"; Description = "File archiver with high compression ratio" },
    @{ Name = "Microsoft.DirectX"; Source = "winget"; Description = "DirectX Runtime" },
    @{ Name = "Microsoft.VCRedist.2015+.x64"; Source = "winget"; Description = "Visual C++ Redistributable" },
    @{ Name = "Microsoft.VCRedist.2015+.x86"; Source = "winget"; Description = "Visual C++ Redistributable (x86)" },
    @{ Name = "ffmpeg"; Source = "choco"; Description = "Video and audio processing tools" },
    @{ Name = "handbrake"; Source = "choco"; Description = "Video transcoder" },
    @{ Name = "youtube-dl"; Source = "choco"; Description = "YouTube downloader" },
    @{ Name = "geforce-game-ready-driver"; Source = "choco"; Description = "NVIDIA GeForce Drivers" },
    
    # Download management
    @{ Name = "JDownloader.JDownloader"; Source = "winget"; Description = "Download management tool" },
    @{ Name = "jdownloader2"; Source = "choco"; Description = "Download management tool (Alternative source)" }
)

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

# Function to check if a package is installed (winget)
function Test-WingetPackageInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )
    
    try {
        $result = winget list --exact --id $PackageId 2>&1
        return $result -match $PackageId
    }
    catch {
        return $false
    }
}

# Function to check if a package is installed (chocolatey)
function Test-ChocolateyPackageInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )
    
    try {
        $installedPackages = choco list --local-only --exact $PackageName
        return $installedPackages -match $PackageName
    }
    catch {
        return $false
    }
}

# Function to install a package using winget
function Install-WingetPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        
        [Parameter(Mandatory = $true)]
        [string]$Description
    )
    
    if (Test-WingetPackageInstalled -PackageId $PackageId) {
        Write-Log -Message "Package '$PackageId' ($Description) is already installed. Skipping." -Level 'Info'
        $script:installationSummary.Skipped += "$PackageId ($Description)"
        return $true
    }
    
    try {
        Write-Log -Message "Installing package '$PackageId' ($Description) using winget..." -Level 'Info'
        & winget install --exact --id $PackageId --accept-source-agreements --accept-package-agreements | Tee-Object -Variable installOutput
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message "Successfully installed '$PackageId'." -Level 'Success'
            $script:installationSummary.Succeeded += "$PackageId ($Description)"
            return $true
        } else {
            Write-Log -Message "Failed to install '$PackageId'. Exit code: $LASTEXITCODE" -Level 'Error'
            $script:installationSummary.Failed += "$PackageId ($Description) - Exit code: $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Log -Message "Error installing '$PackageId': $_" -Level 'Error'
        $script:installationSummary.Failed += "$PackageId ($Description) - Error: $_"
        return $false
    }
}

# Function to install a package using chocolatey
function Install-ChocolateyPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [Parameter(Mandatory = $true)]
        [string]$Description
    )
    
    if (Test-ChocolateyPackageInstalled -PackageName $PackageName) {
        Write-Log -Message "Package '$PackageName' ($Description) is already installed. Skipping." -Level 'Info'
        $script:installationSummary.Skipped += "$PackageName ($Description)"
        return $true
    }
    
    try {
        Write-Log -Message "Installing package '$PackageName' ($Description) using chocolatey..." -Level 'Info'
        & choco install $PackageName -y | Tee-Object -Variable installOutput
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Message "Successfully installed '$PackageName'." -Level 'Success'
            $script:installationSummary.Succeeded += "$PackageName ($Description)"
            return $true
        } else {
            Write-Log -Message "Failed to install '$PackageName'. Exit code: $LASTEXITCODE" -Level 'Error'
            $script:installationSummary.Failed += "$PackageName ($Description) - Exit code: $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Log -Message "Error installing '$PackageName': $_" -Level 'Error'
        $script:installationSummary.Failed += "$PackageName ($Description) - Error: $_"
        return $false
    }
}

# Function to install a package (automatically selects the correct package manager)
function Install-Package {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Package
    )
    
    # Check if the required package manager is available
    if ($Package.Source -eq "winget" -and -not (Test-CommandExists -Command "winget")) {
        Write-Log -Message "Winget is required to install $($Package.Name) but is not available." -Level 'Error'
        $script:installationSummary.Failed += "$($Package.Name) ($($Package.Description)) - Error: Winget not installed"
        return $false
    }
    elseif ($Package.Source -eq "choco" -and -not (Test-CommandExists -Command "choco")) {
        Write-Log -Message "Chocolatey is required to install $($Package.Name) but is not available." -Level 'Error'
        $script:installationSummary.Failed += "$($Package.Name) ($($Package.Description)) - Error: Chocolatey not installed"
        return $false
    }
    
    # Define list of optional packages that might have availability issues
    $optionalPackages = @(
        "1g1r", 
        "jdownloader2", 
        "mister-devel.update_all", 
        "mister-devel.mister_offline", 
        "mister-tools", 
        "MiSTer.MiSTerConfigurator", 
        "mister-ini-editor", 
        "mister-batch-control", 
        "mister-wifi-config"
    )
    
    # Special handling for packages that might have availability issues
    if ($optionalPackages -contains $Package.Name) {
        Write-Log -Message "Attempting to install optional package '$($Package.Name)' ($($Package.Description))..." -Level 'Info'
        try {
            if ($Package.Source -eq "winget") {
                return Install-WingetPackage -PackageId $Package.Name -Description $Package.Description
            }
            elseif ($Package.Source -eq "choco") {
                return Install-ChocolateyPackage -PackageName $Package.Name -Description $Package.Description
            }
        }
        catch {
            Write-Log -Message "Optional package '$($Package.Name)' installation failed, but continuing: $_" -Level 'Warning'
            $script:installationSummary.Failed += "$($Package.Name) ($($Package.Description)) - Warning: Optional package failed"
            return $false
        }
    }
    
    # Standard package installation
    if ($Package.Source -eq "winget") {
        return Install-WingetPackage -PackageId $Package.Name -Description $Package.Description
    }
    elseif ($Package.Source -eq "choco") {
        return Install-ChocolateyPackage -PackageName $Package.Name -Description $Package.Description
    }
    else {
        Write-Log -Message "Unknown package source '$($Package.Source)' for package '$($Package.Name)'." -Level 'Error'
        $script:installationSummary.Failed += "$($Package.Name) ($($Package.Description)) - Error: Unknown source"
        return $false
    }
}

# Function to install packages from a specified category
function Install-Category {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Packages,
        
        [Parameter(Mandatory = $true)]
        [string]$CategoryName
    )
    
    Write-Log -Message "Starting installation of $CategoryName packages..." -Level 'Info'
    $totalPackages = $Packages.Count
    $installedCount = 0
    
    foreach ($package in $Packages) {
        $installedCount++
        Write-Host "`nInstalling package $installedCount of $totalPackages in $CategoryName category" -ForegroundColor Yellow
        if (Install-Package -Package $package) {
            # Successfully installed or skipped (already installed)
        }
        else {
            # Failed to install
        }
    }
    
    Write-Log -Message "Completed installation of $CategoryName packages." -Level 'Info'
}

# Function to display the main menu
function Show-MainMenu {
    Clear-Host
    Write-Host "================ Developer Tools Installation ================" -ForegroundColor Green
    Write-Host "1. Install Development Tools (VS Code, Git, Python, etc.)" -ForegroundColor Cyan
    Write-Host "2. Install FPGA Tools (Xilinx Vivado, Intel Quartus, MiSTer, etc.)" -ForegroundColor Cyan
    Write-Host "3. Install Gaming/Emulation Tools (RetroArch, Dolphin, etc.)" -ForegroundColor Cyan
    Write-Host "4. Install ROM Management Tools (LaunchBox, RomVault, etc.)" -ForegroundColor Cyan
    Write-Host "5. Install Supporting Tools (7-Zip, DirectX, etc.)" -ForegroundColor Cyan
    Write-Host "6. Install Handheld Device Tools (Pocket Updater, Pocket Sync)" -ForegroundColor Cyan
    Write-Host "7. Install MiSTer FPGA Tools" -ForegroundColor Cyan
    Write-Host "8. Install All Categories" -ForegroundColor Yellow
    Write-Host "9. Custom Installation (Select individual packages)" -ForegroundColor Yellow
    Write-Host "Q. Quit" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    return Read-Host "Enter your choice (1-7 or Q)"
}

# Function to display all packages in a category for selection
function Show-PackageSelectionMenu {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Packages,
        
        [Parameter(Mandatory = $true)]
        [string]$CategoryName
    )
    
    Clear-Host
    Write-Host "================== $CategoryName Packages ==================" -ForegroundColor Green
    
    $packageCount = $Packages.Count
    for ($i = 0; $i -lt $packageCount; $i++) {
        Write-Host "$($i + 1). $($Packages[$i].Name) - $($Packages[$i].Description) ($($Packages[$i].Source))" -ForegroundColor Cyan
    }
    
    Write-Host "A. Install All $CategoryName Packages" -ForegroundColor Yellow
    Write-Host "N. None / Return to Main Menu" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    
    $selection = Read-Host "Enter package numbers to install (comma-separated, e.g., 1,3,5), 'A' for all, or 'N' for none"
    
    if ($selection -eq 'N' -or $selection -eq 'n') {
        return @()
    }
    elseif ($selection -eq 'A' -or $selection -eq 'a') {
        return $Packages
    }
    else {
        $selectedIndices = $selection -split ',' | ForEach-Object { $_.Trim() }
        $selectedPackages = @()
        
        foreach ($index in $selectedIndices) {
            if ([int]::TryParse($index, [ref]$null)) {
                $adjustedIndex = [int]$index - 1
                if ($adjustedIndex -ge 0 -and $adjustedIndex -lt $packageCount) {
                    $selectedPackages += $Packages[$adjustedIndex]
                }
            }
        }
        
        return $selectedPackages
    }
}

# Function to display installation summary
function Show-InstallationSummary {
    Clear-Host
    Write-Host "================ Installation Summary ================" -ForegroundColor Green
    
    # Calculate duration
    $duration = $installationSummary.EndTime - $installationSummary.StartTime
    
    Write-Host "Start Time: $($installationSummary.StartTime)" -ForegroundColor Cyan
    Write-Host "End Time: $($installationSummary.EndTime)" -ForegroundColor Cyan
    Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Successful Installations ($($installationSummary.Succeeded.Count)):" -ForegroundColor Green
    if ($installationSummary.Succeeded.Count -gt 0) {
        foreach ($package in $installationSummary.Succeeded) {
            Write-Host "  - $package" -ForegroundColor Green
        }
    } else {
        Write-Host "  None" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Skipped Installations ($($installationSummary.Skipped.Count)):" -ForegroundColor Yellow
    if ($installationSummary.Skipped.Count -gt 0) {
        foreach ($package in $installationSummary.Skipped) {
            Write-Host "  - $package" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  None" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Failed Installations ($($installationSummary.Failed.Count)):" -ForegroundColor Red
    if ($installationSummary.Failed.Count -gt 0) {
        foreach ($package in $installationSummary.Failed) {
            Write-Host "  - $package" -ForegroundColor Red
        }
    } else {
        Write-Host "  None" -ForegroundColor Gray
    }
    
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host "Log file location: $logFile" -ForegroundColor Cyan
    
    # Add installation counts to the log
    Write-Log -Message "Installation complete. Summary:" -Level 'Info'
    Write-Log -Message "  Total duration: $($duration.ToString('hh\:mm\:ss'))" -Level 'Info'
    Write-Log -Message "  Successful installations: $($installationSummary.Succeeded.Count)" -Level 'Info'
    Write-Log -Message "  Skipped installations: $($installationSummary.Skipped.Count)" -Level 'Info'
    Write-Log -Message "  Failed installations: $($installationSummary.Failed.Count)" -Level 'Info'
}

# Function to verify package managers are available
function Test-PackageManagers {
    $hasWinget = Test-CommandExists -Command "winget"
    $hasChocolatey = Test-CommandExists -Command "choco"
    
    if (-not $hasWinget -and -not $hasChocolatey) {
        Write-Log -Message "Neither winget nor chocolatey are installed. Cannot proceed with installation." -Level 'Error'
        Write-Host "Error: Neither winget nor chocolatey are installed." -ForegroundColor Red
        Write-Host "Please install at least one of these package managers before running this script." -ForegroundColor Red
        Write-Host "Winget: Included with newer Windows versions or from the Microsoft Store" -ForegroundColor Yellow
        Write-Host "Chocolatey: https://chocolatey.org/install" -ForegroundColor Yellow
        return $false
    }
    
    if (-not $hasWinget) {
        Write-Log -Message "Winget is not installed. Some packages may not be available." -Level 'Warning'
        Write-Host "Warning: Winget is not installed. Some packages may not be available." -ForegroundColor Yellow
    }
    
    if (-not $hasChocolatey) {
        Write-Log -Message "Chocolatey is not installed. Some packages may not be available." -Level 'Warning'
        Write-Host "Warning: Chocolatey is not installed. Some packages may not be available." -ForegroundColor Yellow
    }
    
    return $true
}

# Function to perform custom installation
function Start-CustomInstallation {
    $categoriesToInstall = @()
    
    # Development Tools
    $selectedDevTools = Show-PackageSelectionMenu -Packages $developmentTools -CategoryName "Development Tools"
    if ($selectedDevTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedDevTools
            CategoryName = "Development Tools"
        }
    }
    
    # FPGA Tools
    $selectedFpgaTools = Show-PackageSelectionMenu -Packages $fpgaTools -CategoryName "FPGA Tools"
    if ($selectedFpgaTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedFpgaTools
            CategoryName = "FPGA Tools"
        }
    }
    
    # Gaming/Emulation Tools
    $selectedGamingTools = Show-PackageSelectionMenu -Packages $gamingEmulationTools -CategoryName "Gaming/Emulation Tools"
    if ($selectedGamingTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedGamingTools
            CategoryName = "Gaming/Emulation Tools"
        }
    }
    
    # ROM Management Tools
    $selectedRomTools = Show-PackageSelectionMenu -Packages $romManagementTools -CategoryName "ROM Management Tools"
    if ($selectedRomTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedRomTools
            CategoryName = "ROM Management Tools"
        }
    }
    
    # Supporting Tools
    $selectedSupportingTools = Show-PackageSelectionMenu -Packages $supportingTools -CategoryName "Supporting Tools"
    if ($selectedSupportingTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedSupportingTools
            CategoryName = "Supporting Tools"
        }
    }
    
    # Handheld Device Tools
    $selectedHandheldTools = Show-PackageSelectionMenu -Packages $handheldDeviceTools -CategoryName "Handheld Device Tools"
    if ($selectedHandheldTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedHandheldTools
            CategoryName = "Handheld Device Tools"
        }
    }
    
    # MiSTer FPGA Tools
    $selectedMisterTools = Show-PackageSelectionMenu -Packages $misterTools -CategoryName "MiSTer FPGA Tools"
    if ($selectedMisterTools.Count -gt 0) {
        $categoriesToInstall += @{
            Packages = $selectedMisterTools
            CategoryName = "MiSTer FPGA Tools"
        }
    }
    
    # Install selected packages
    foreach ($category in $categoriesToInstall) {
        Install-Category -Packages $category.Packages -CategoryName $category.CategoryName
    }
}

# Main execution block
try {
    # Start logging
    Write-Log -Message "Starting Dev Tools installation script" -Level 'Info'
    
    # Check if package managers are available
    if (-not (Test-PackageManagers)) {
        exit 1
    }
    
    # Parse command-line arguments if any
    param (
        [Parameter(Mandatory = $false)]
        [switch]$AllCategories,
        
        [Parameter(Mandatory = $false)]
        [switch]$DevTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$FpgaTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$GamingTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$RomTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$SupportingTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$HandheldTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$MisterTools,
        
        [Parameter(Mandatory = $false)]
        [switch]$NonInteractive
    )
    
    # Non-interactive mode with command-line parameters
    if ($NonInteractive -or $AllCategories -or $DevTools -or $FpgaTools -or $GamingTools -or $RomTools -or $SupportingTools -or $HandheldTools -or $MisterTools) {
        if ($AllCategories -or $DevTools) {
            Install-Category -Packages $developmentTools -CategoryName "Development Tools"
        }
        
        if ($AllCategories -or $FpgaTools) {
            Install-Category -Packages $fpgaTools -CategoryName "FPGA Tools"
        }
        
        if ($AllCategories -or $GamingTools) {
            Install-Category -Packages $gamingEmulationTools -CategoryName "Gaming/Emulation Tools"
        }
        
        if ($AllCategories -or $RomTools) {
            Install-Category -Packages $romManagementTools -CategoryName "ROM Management Tools"
        }
        
        if ($AllCategories -or $SupportingTools) {
            Install-Category -Packages $supportingTools -CategoryName "Supporting Tools"
        }
        
        if ($AllCategories -or $HandheldTools) {
            Install-Category -Packages $handheldDeviceTools -CategoryName "Handheld Device Tools"
        }
        
        if ($AllCategories -or $MisterTools) {
            Install-Category -Packages $misterTools -CategoryName "MiSTer FPGA Tools"
        }
    }
    # Interactive mode with menu
    else {
        $choice = ""
        while ($choice -ne "Q" -and $choice -ne "q") {
            $choice = Show-MainMenu
            
            switch ($choice) {
                "1" {
                    Install-Category -Packages $developmentTools -CategoryName "Development Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "2" {
                    Install-Category -Packages $fpgaTools -CategoryName "FPGA Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "3" {
                    Install-Category -Packages $gamingEmulationTools -CategoryName "Gaming/Emulation Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "4" {
                    Install-Category -Packages $romManagementTools -CategoryName "ROM Management Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "5" {
                    Install-Category -Packages $supportingTools -CategoryName "Supporting Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "7" {
                    Install-Category -Packages $misterTools -CategoryName "MiSTer FPGA Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "8" {
                    Install-Category -Packages $developmentTools -CategoryName "Development Tools"
                    Install-Category -Packages $fpgaTools -CategoryName "FPGA Tools"
                    Install-Category -Packages $gamingEmulationTools -CategoryName "Gaming/Emulation Tools"
                    Install-Category -Packages $romManagementTools -CategoryName "ROM Management Tools"
                    Install-Category -Packages $supportingTools -CategoryName "Supporting Tools"
                    Install-Category -Packages $handheldDeviceTools -CategoryName "Handheld Device Tools"
                    Install-Category -Packages $misterTools -CategoryName "MiSTer FPGA Tools"
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "9" {
                    Start-CustomInstallation
                    Write-Host "Press any key to continue..."
                    [void][System.Console]::ReadKey($true)
                }
                "Q" { continue }
                "q" { continue }
                default {
                    Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
        }
    }
    
    # Update end time
    $installationSummary.EndTime = Get-Date
    
    # Show installation summary
    Show-InstallationSummary
    
    # Exit successfully
    exit 0
}
catch {
    # Log error
    Write-Log -Message "An error occurred during execution: $_" -Level 'Error'
    Write-Host "An error occurred during execution: $_" -ForegroundColor Red
    
    # Update end time for summary
    $installationSummary.EndTime = Get-Date
    
    # Show installation summary even if there was an error
    Show-InstallationSummary
    
    # Exit with error
    exit 1
}
