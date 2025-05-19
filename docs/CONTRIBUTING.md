# Contributing to Windows System Update Script

Thank you for considering contributing to the Windows System Update Script! This document outlines the guidelines for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Package Contribution Guidelines](#package-contribution-guidelines)
  - [Adding New Packages](#adding-new-packages)
  - [Updating Existing Packages](#updating-existing-packages)
  - [Testing Requirements](#testing-requirements)
  - [Package Entry Style Guide](#package-entry-style-guide)
  - [Package Documentation](#package-documentation)
- [Coding Style Guidelines](#coding-style-guidelines)
- [Testing](#testing)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone. Please:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please create an issue with the following information:

- A clear descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Your environment (Windows version, PowerShell version, etc.)
- Any additional context

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- A clear and descriptive title
- A detailed description of the proposed functionality
- Rationale: why this enhancement would be useful
- Possible implementation
- Any relevant examples

### Pull Requests

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

#### Pull Request Guidelines

- Update the README.md with details of changes if applicable
- Update the documentation if needed
- The PR should work for PowerShell 7.0 and above
- Follow the PowerShell coding style (see below)

## Package Contribution Guidelines

One of the most common ways to contribute to this project is by adding new software packages or updating existing ones in the `Install-DevTools.ps1` script. The following guidelines will help ensure your package contributions are accepted quickly.

### Adding New Packages

When adding new packages to the script, please follow these guidelines:

1. **Verify the package ID**:
   - For **winget** packages: Use `winget search [package]` to find the exact ID
   - For **chocolatey** packages: Use `choco search [package]` to find the exact name

2. **Choose the appropriate category**:
   - Add the package to an existing category if it fits
   - If proposing a new category, include at least 3-5 related packages

3. **Include required information**:
   ```powershell
   @{ 
       Name = "ExactPackageId";  # Must be the exact ID/name from the package manager
       Source = "winget";        # Must be either "winget" or "choco"
       Description = "Clear, concise description of the package"
   }
   ```

4. **Avoid duplicates**:
   - Check if the package already exists in any category before adding
   - If it exists but is in the wrong category, propose moving it instead of duplicating

5. **Consider popularity and maintenance**:
   - Add packages that are generally useful to many users
   - Prefer packages that are actively maintained
   - For specialized tools, include a brief explanation of their importance

### Updating Existing Packages

When updating existing package entries:

1. **Package ID changes**:
   - If a package ID has changed, update it and note the change in your PR description
   - Include evidence of the ID change (e.g., output from `winget search`)

2. **Package source changes**:
   - If a package should be switched from one source to another (e.g., from chocolatey to winget), include the rationale

3. **Removing packages**:
   - Only propose removal if the package is deprecated, no longer maintained, or has security issues
   - Provide evidence supporting the removal

4. **Updating descriptions**:
   - Keep descriptions clear and concise
   - Ensure descriptions reflect the current functionality of the package

### Testing Requirements

All package contributions must be tested before submission:

1. **Installation testing**:
   ```powershell
   # For winget packages
   winget install --exact --id [PackageId]
   
   # For chocolatey packages
   choco install [PackageName] -y
   ```

2. **Verification steps**:
   - Verify the package installs without errors
   - Launch the installed application to confirm it works properly
   - For developer tools, perform a basic operation (e.g., compile a hello world program)

3. **Include test results**:
   - In your PR description, include:
     - Your OS version
     - PowerShell version
     - Brief summary of test results

4. **Clean environment testing** (recommended):
   - Test on a clean environment like a VM or container if possible
   - Note any dependencies that were automatically installed

### Package Entry Style Guide

Follow these style guidelines for package entries:

1. **Formatting**:
   ```powershell
   # Correct format with aligned properties
   @{ 
       Name = "Package.Id";
       Source = "winget";
       Description = "Package description"
   }
   
   # Compact format for simple entries is also acceptable
   @{ Name = "Package.Id"; Source = "winget"; Description = "Package description" }
   ```

2. **Ordering**:
   - Order packages alphabetically within their category
   - For dependencies, place dependencies before dependent packages

3. **Grouping**:
   - Group related packages together with a comment separator
   - Example:
     ```powershell
     # Python development tools
     @{ Name = "Python.Python.3"; Source = "winget"; Description = "Python programming language" },
     @{ Name = "pip"; Source = "choco"; Description = "Package manager for Python" },
     
     # JavaScript development tools
     @{ Name = "OpenJS.NodeJS"; Source = "winget"; Description = "JavaScript runtime" },
     @{ Name = "yarn"; Source = "choco"; Description = "Package manager for Node.js" },
     ```

### Package Documentation

When adding new packages or categories, update documentation as needed:

1. **For new categories**:
   - Add the category to the README.md in the appropriate section
   - Create examples in the docs/configuration.md file

2. **For significant packages**:
   - Consider adding usage examples in the documentation
   - If the package requires special configuration, add notes

3. **For complex installations**:
   - If a package requires special installation steps, include these in comments
   - Example:
     ```powershell
     # Note: The FooCorp.SpecialTool package requires manual acceptance of license
     # on first run and 10GB+ of free disk space
     @{ Name = "FooCorp.SpecialTool"; Source = "winget"; Description = "Specialized development tool" },
     ```

## Coding Style Guidelines

### PowerShell Style

- Use PascalCase for function names and camelCase for variable names
- Include comment-based help for functions
- Use meaningful variable names
- Follow the [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)

### Example of Good PowerShell Code

```powershell
function Get-SystemStatus {
    <#
    .SYNOPSIS
        Gets the current system status.
    .DESCRIPTION
        Retrieves various metrics about the current system status.
    .PARAMETER ComputerName
        The name of the computer to check.
    .EXAMPLE
        Get-SystemStatus -ComputerName "MyPC"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    $systemInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
    
    return [PSCustomObject]@{
        ComputerName = $ComputerName
        LastBootTime = $systemInfo.LastBootUpTime
        FreeMemory = $systemInfo.FreePhysicalMemory
        UpTime = (Get-Date) - $systemInfo.LastBootUpTime
    }
}
```

## Testing

Please test your changes thoroughly before submitting a pull request. This includes:

- Basic functionality testing
- Testing on different Windows versions if possible
- Testing with different package manager configurations

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.

## Questions?

If you have any questions, please feel free to create an issue with the tag "question".

