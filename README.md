# Windows System Update Script

A comprehensive PowerShell script for automating system updates on Windows systems using multiple package managers (winget, Chocolatey) and Windows Update.

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

This repository contains PowerShell scripts for Windows system maintenance and software installation:

1. **Update-System.ps1**: Automates the update process for Windows systems
2. **Install-DevTools.ps1**: Installs specialized software for development, FPGA, gaming, and more

### Update-System.ps1

This script automates the update process for Windows systems by combining multiple update mechanisms into a single, convenient script:

- Windows package management with **winget**
- Software packages installed via **Chocolatey**
- Windows system updates using the **PSWindowsUpdate** module

The script includes robust error handling, detailed logging, and administrative privilege verification to ensure updates are properly applied.

### Install-DevTools.ps1

This script provides an interactive and automated way to install specialized software in several categories:

- **Development Tools**: VS Code, Git, Python, Node.js, Visual Studio, Docker Desktop, etc.
- **FPGA Tools**: Xilinx Vivado, Intel Quartus, Yosys, NextPNR, etc.
- **Gaming/Emulation Tools**: RetroArch, Dolphin, PCSX2, RPCS3, Citra, etc.
- **ROM Management Tools**: LaunchBox, ROMCenter, ClrMamePro, Rufus, MAME Tools, SabreTools, RomVault, etc.
- **Handheld Device Tools**: Analogue Pocket Updater, Pocket Sync
- **Supporting Tools**: 7-Zip, DirectX, Visual C++ Redistributables, NVIDIA drivers, etc.

The script validates if the required package managers are installed, checks if packages are already installed before attempting installation, and provides detailed logs and summaries of all operations.

## Prerequisites

- **Windows 10/11** operating system
- **PowerShell 7.0 or higher** (scripts will not work properly with Windows PowerShell 5.1)
- **Administrator privileges** (required for installation and updates)
- **Package managers**:
  - [winget](https://github.com/microsoft/winget-cli) (Windows Package Manager)
  - [Chocolatey](https://chocolatey.org/install) (Optional for Update-System.ps1, but enables more packages in Install-DevTools.ps1)
- Internet connectivity
- For FPGA development: Sufficient disk space (20+ GB) for tools like Xilinx Vivado or Intel Quartus
- For Gaming/Emulation: A capable GPU for optimal performance
- For Handheld Device Tools: USB connectivity for device management

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

### Update-System.ps1

#### Basic Usage

Run the script with administrative privileges:

```powershell
# Navigate to the script location (if using the git clone method)
cd path\to\windows-update-script

# Run the script
.\Update-System.ps1
```

#### Scheduled Task

You can set up a scheduled task to run this script automatically:

1. Open Task Scheduler
2. Create a new task with these settings:
   - Run with highest privileges
   - Configure for: Windows 10 (or your version)
   - Trigger: On a schedule (e.g., weekly)
   - Action: Start a program
     - Program/script: `powershell.exe`
     - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\Update-System.ps1"`

### Install-DevTools.ps1

#### Interactive Mode

Run the script with administrative privileges to use the interactive menu:

```powershell
# Navigate to the script location
cd path\to\windows-update-script

# Run the script with interactive menu
.\Install-DevTools.ps1
```

This will display a menu with the following options:
1. Install Development Tools
2. Install FPGA Tools
3. Install Gaming/Emulation Tools
4. Install ROM Management Tools
5. Install Supporting Tools
6. Install Handheld Device Tools
7. Install All Categories
8. Custom Installation (select individual packages)

#### Non-Interactive Mode

You can also run the script with parameters for automated installation:

```powershell
# Install all development tools
.\Install-DevTools.ps1 -DevTools

# Install FPGA and gaming tools
.\Install-DevTools.ps1 -FpgaTools -GamingTools

# Install all categories
.\Install-DevTools.ps1 -AllCategories

# Available parameters
# -DevTools         : Install development tools
# -FpgaTools        : Install FPGA development tools
# -GamingTools      : Install gaming/emulation tools
# -RomTools         : Install ROM management tools
# -SupportingTools  : Install supporting tools
# -HandheldTools    : Install handheld device management tools
# -AllCategories    : Install all categories
# -NonInteractive   : Run in non-interactive mode
```

## Features

### Update-System.ps1

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

### Install-DevTools.ps1

- **Interactive Menu System**: Easy-to-use interface for selecting software to install
- **Multi-Package Manager Support**:
  - Windows Package Manager (winget)
  - Chocolatey Package Manager
- **Specialized Software Categories**:
  - Development tools for programmers
  - FPGA development tools
  - Gaming and emulation software
  - ROM management utilities
  - Handheld device management tools
  - Supporting system tools
- **Smart Installation**:
  - Skips already installed packages
  - Handles dependencies automatically
  - Adapts to available package managers
- **Custom Installation**: Cherry-pick specific packages from each category
- **Command-Line Parameters**: Support for automated/scripted installation
- **Comprehensive Logging and Summary**: Track all installation operations

## Logs

Both scripts store logs in the `%USERPROFILE%\Logs` directory:

- **Update-System.ps1**: `SystemUpdate_[TIMESTAMP].log`
- **Install-DevTools.ps1**: `DevTools_Installation_[TIMESTAMP].log`

The log files contain detailed information about:
- Start and end times
- Success or failure of each operation
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

