# Windows System Update Script

A comprehensive PowerShell script for automating system updates on Windows systems using multiple package managers (winget, Chocolatey) and Windows Update.

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

This script automates the update process for Windows systems by combining multiple update mechanisms into a single, convenient script:

- Windows package management with **winget**
- Software packages installed via **Chocolatey**
- Windows system updates using the **PSWindowsUpdate** module

The script includes robust error handling, detailed logging, and administrative privilege verification to ensure updates are properly applied.

## Prerequisites

- **Windows 10/11** operating system
- **PowerShell 7.0 or higher** (script will not work properly with Windows PowerShell 5.1)
- **Administrator privileges** (required for installation and updates)
- **Package managers**:
  - [winget](https://github.com/microsoft/winget-cli) (Windows Package Manager)
  - [Chocolatey](https://chocolatey.org/install) (Optional, but recommended)
- Internet connectivity

## Installation

### Option 1: Git Clone (Recommended)

1. Clone this repository:
   ```powershell
   git clone https://github.com/yourusername/windows-update-script.git
   cd windows-update-script
   ```

### Option 2: Direct Download

1. Download the script file directly:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/windows-update-script/main/Update-System.ps1" -OutFile "$env:USERPROFILE\Update-System.ps1"
   ```

### Option 3: Manual Installation

1. Create a new PowerShell script file named `Update-System.ps1`
2. Copy the contents from [Update-System.ps1](./Update-System.ps1) in this repository
3. Save the file to a location of your choice

## Usage

### Basic Usage

Run the script with administrative privileges:

```powershell
# Navigate to the script location (if using the git clone method)
cd path\to\windows-update-script

# Run the script
.\Update-System.ps1
```

### Scheduled Task

You can set up a scheduled task to run this script automatically:

1. Open Task Scheduler
2. Create a new task with these settings:
   - Run with highest privileges
   - Configure for: Windows 10 (or your version)
   - Trigger: On a schedule (e.g., weekly)
   - Action: Start a program
     - Program/script: `powershell.exe`
     - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"`

## Features

- **Administrative Privilege Check**: Ensures the script is run with the proper permissions
- **Multi-Package Manager Support**:
  - Windows Package Manager (winget)
  - Chocolatey Package Manager
  - Windows Update
- **Comprehensive Logging**: Detailed logs of all operations
  - Creates timestamped log files in `%USERPROFILE%\Logs`
  - Color-coded console output
- **Error Handling**: Graceful handling of failures
- **Update Summary**: Provides a concise summary of update operations

## Logs

By default, logs are stored in:
```
%USERPROFILE%\Logs\SystemUpdate_[TIMESTAMP].log
```

The log file contains detailed information about:
- Start and end times
- Success or failure of each update operation
- Errors encountered during execution
- Summary of all operations

## Customization

You can modify the script to customize its behavior:

- Change the log directory by modifying the `$logDirectory` variable
- Adjust error handling by modifying the `$ErrorActionPreference` variable
- Add or remove update mechanisms as needed

See the [documentation](./docs/configuration.md) for more detailed customization options.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Microsoft for [winget](https://github.com/microsoft/winget-cli)
- Chocolatey team for [Chocolatey](https://chocolatey.org/)
- PSWindowsUpdate module contributors

