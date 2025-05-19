# Contributing to Windows System Update Script

Thank you for considering contributing to the Windows System Update Script! This document outlines the guidelines for contributing to this project.

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

