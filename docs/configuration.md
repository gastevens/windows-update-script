# Configuration Options

This document outlines the various configuration options available in the Windows System Update Scripts.

## Table of Contents
- [Update-System.ps1 Configuration](#update-systemps1-configuration)
- [Install-DevTools.ps1 Customization](#install-devtoolsps1-customization)
  - [Customizing Package Lists](#customizing-package-lists)
  - [Adding New Packages](#adding-new-packages)
  - [Creating New Software Categories](#creating-new-software-categories)
  - [Common Customization Examples](#common-customization-examples)
  - [Package Management Best Practices](#package-management-best-practices)

## Update-System.ps1 Configuration

### Core Configuration Variables

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

## Install-DevTools.ps1 Customization

The `Install-DevTools.ps1` script is designed to be easily customizable to include your preferred software packages and categories.

### Customizing Package Lists

Package lists are defined at the beginning of the script as PowerShell arrays containing hashtable objects. Each package category is stored in its own variable (e.g., `$developmentTools`, `$fpgaTools`, etc.).

Here's how a package list is structured:

```powershell
$categoryName = @(
    @{ Name = "PackageId"; Source = "winget/choco"; Description = "Package description" },
    # Additional packages...
)
```

### Adding New Packages

To add a new package to an existing category:

1. Locate the appropriate category array in the script (e.g., `$developmentTools`)
2. Add a new hashtable entry with the following properties:
   - `Name`: The package ID (for winget) or package name (for chocolatey)
   - `Source`: Either "winget" or "choco" depending on the package source
   - `Description`: A brief description of the package

Example:

```powershell
# Adding Visual Studio Code Insiders to development tools
$developmentTools += @{ 
    Name = "Microsoft.VisualStudioCode.Insiders"; 
    Source = "winget"; 
    Description = "Visual Studio Code Insiders build" 
}
```

#### Finding Package IDs

- For **winget** packages:
  ```powershell
  winget search [search-term]
  ```
  Use the "Id" column from the results.

- For **chocolatey** packages:
  ```powershell
  choco search [search-term]
  ```
  Use the package name from the results.

### Creating New Software Categories

To create an entirely new software category:

1. Define a new array variable at the beginning of the script:

```powershell
$newCategory = @(
    @{ Name = "Package1"; Source = "winget"; Description = "Description 1" },
    @{ Name = "Package2"; Source = "choco"; Description = "Description 2" }
    # Add more packages as needed
)
```

2. Add a new menu option in the `Show-MainMenu` function:

```powershell
function Show-MainMenu {
    # Existing code...
    Write-Host "8. Install New Category" -ForegroundColor Cyan
    # Continue with existing code...
}
```

3. Add a case for the new option in the switch statement in the main execution block:

```powershell
switch ($choice) {
    # Existing cases...
    "8" {
        Install-Category -Packages $newCategory -CategoryName "New Category"
        Write-Host "Press any key to continue..."
        [void][System.Console]::ReadKey($true)
    }
    # Continue with existing cases...
}
```

4. Add a new command-line parameter in the param block:

```powershell
param (
    # Existing parameters...
    [Parameter(Mandatory = $false)]
    [switch]$NewCategory
)
```

5. Update the non-interactive mode section:

```powershell
if ($AllCategories -or $NewCategory) {
    Install-Category -Packages $newCategory -CategoryName "New Category"
}
```

### Common Customization Examples

#### Example 1: Adding Game Development Tools

```powershell
# Add a new category for game development
$gameDevTools = @(
    @{ Name = "Unity.UnityHub"; Source = "winget"; Description = "Unity Hub for Unity Engine" },
    @{ Name = "Unreal.UnrealEngine"; Source = "winget"; Description = "Unreal Engine" },
    @{ Name = "godot"; Source = "choco"; Description = "Godot Engine" },
    @{ Name = "blender"; Source = "choco"; Description = "Blender 3D modeling software" }
)

# Then follow steps 2-5 from "Creating New Software Categories" to integrate it
```

#### Example 2: Adding Programming Languages

```powershell
# Add additional programming languages to development tools
$developmentTools += @(
    @{ Name = "Rustlang.Rust"; Source = "winget"; Description = "Rust programming language" },
    @{ Name = "golang"; Source = "choco"; Description = "Go programming language" },
    @{ Name = "ruby"; Source = "choco"; Description = "Ruby programming language" },
    @{ Name = "OpenJDK.OpenJDK"; Source = "winget"; Description = "Open Java Development Kit" }
)
```

#### Example 3: Adding Design Tools

```powershell
# Create a new category for design tools
$designTools = @(
    @{ Name = "Adobe.Photoshop"; Source = "winget"; Description = "Adobe Photoshop" },
    @{ Name = "GIMP.GIMP"; Source = "winget"; Description = "GIMP image editor" },
    @{ Name = "Inkscape.Inkscape"; Source = "winget"; Description = "Inkscape vector graphics editor" },
    @{ Name = "figma"; Source = "choco"; Description = "Figma design tool" }
)

# Then follow steps 2-5 from "Creating New Software Categories" to integrate it
```

### Package Management Best Practices

#### 1. Verify Package IDs

Always verify the exact package ID before adding it to the script. Incorrect IDs will cause installation failures.

#### 2. Balance Between Winget and Chocolatey

- Use **winget** as the primary source when possible, as it's built into Windows
- Use **chocolatey** for packages not available in winget or that require special installation procedures

#### 3. Consider Dependencies

Be aware that some packages have dependencies that need to be installed first. For such packages:

- Make sure dependencies are listed before the dependent packages
- Consider using package manager-specific commands to handle complex dependencies

#### 4. Testing New Packages

Always test a new package manually before adding it to your script:

```powershell
# For winget
winget install --exact --id [PackageId]

# For chocolatey
choco install [PackageName] -y
```

#### 5. Updating Package Lists

Periodically update your package lists to:
- Remove deprecated packages
- Update package IDs if they've changed
- Add new useful packages that have become available

#### 6. Managing Large Package Lists

For very large package lists, consider moving the definitions to a separate JSON or XML file and loading them in the script:

```powershell
# Example with JSON
$developmentTools = Get-Content -Path ".\config\dev-tools.json" | ConvertFrom-Json
```

This makes maintenance easier as your lists grow.

## Special Package Handling

Some packages require special handling due to availability issues or installation complexities. The `Install-DevTools.ps1` script includes mechanisms to handle these special cases.

### Fallback Mechanism for Multiple Sources

For packages available from multiple package managers, you can implement a fallback mechanism to improve installation reliability:

```powershell
# Example of a package with multiple sources (like JDownloader 2)
$supportingTools = @(
    # Other packages...
    
    # Primary source from winget
    @{ Name = "JDownloader.JDownloader"; Source = "winget"; Description = "Download management tool" },
    # Alternative source from chocolatey
    @{ Name = "jdownloader2"; Source = "choco"; Description = "Download management tool (Alternative source)" }
)
```

When both package sources are included separately like this, the script will try to install either one, and if the first one is already installed, it will skip the second one.

### Special Handling for Optional Packages

For packages that may not be available in standard repositories or that are considered optional:

```powershell
# In the Install-Package function
# Special handling for packages that might have availability issues
if ($Package.Name -eq "1g1r" -or $Package.Name -eq "jdownloader2") {
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
```

This code allows the script to continue even if an optional package installation fails, rather than terminating the entire script.

### Adding More Packages with Special Handling

To add additional packages that require special handling:

1. Add the package to the appropriate category list:
   ```powershell
   $romManagementTools += @{ 
       Name = "specialized-rom-tool"; 
       Source = "choco"; 
       Description = "Specialized ROM management tool" 
   }
   ```

2. Update the special handling condition in the `Install-Package` function:
   ```powershell
   if ($Package.Name -eq "1g1r" -or $Package.Name -eq "jdownloader2" -or $Package.Name -eq "specialized-rom-tool") {
       # Special handling code
   }
   ```

3. Consider creating a more robust solution for many optional packages:
   ```powershell
   # Define optional packages in a list
   $optionalPackages = @("1g1r", "jdownloader2", "specialized-rom-tool")
   
   # Then in the Install-Package function
   if ($optionalPackages -contains $Package.Name) {
       # Special handling code
   }
   ```

### Best Practices for Managing Packages with Multiple Sources

1. **Prioritize Package Managers**:
   - List winget packages first as they are generally more integrated with Windows
   - Use chocolatey as a fallback when winget packages are unavailable

2. **Clear Descriptions**:
   - Add clarifying text in the description for alternative sources (e.g., "Alternative source")
   - Ensure package purpose is clear in both sources' descriptions

3. **Version and Update Considerations**:
   - Be aware that different package managers may have different update schedules
   - Consider adding version numbers in descriptions for clarity

4. **Testing Both Sources**:
   - Always test installation from both sources before adding to the script
   - Document any special behaviors or post-installation requirements

5. **Handling Duplicate Installations**:
   - The script is designed to skip packages that are already installed
   - This prevents duplicate installations when both sources of a package are listed

6. **Custom Validation Logic**:
   - For complex cases, you can add custom validation logic:
   ```powershell
   function Test-CustomPackageInstalled {
       param (
           [Parameter(Mandatory = $true)]
           [string]$PackageName
       )
       
       # Custom logic to check if package is installed
       # For example, check for specific files or registry entries
       
       return $false # or $true based on checks
   }
   
   # Then use this in your package installation logic
   if (Test-CustomPackageInstalled -PackageName $Package.Name) {
       # Skip installation
   }
   ```

