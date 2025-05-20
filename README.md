# SMDB to DAT Conversion Tool

A PowerShell tool for converting SMDB (Software Management Database) files to DAT format for use with ROMVault and other ROM management tools.

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

This tool converts SMDB (Software Management Database) files to DAT format files compatible with ROMVault and other ROM management tools. It's designed to help retro gaming enthusiasts manage their ROM collections more effectively.

SMDB files are commonly used in ROM management for various systems including MiSTer FPGA, EverDrive flashcarts, and other retro gaming platforms. Converting them to DAT format makes them compatible with popular ROM management tools like ROMVault, ClrMamePro, and RomCenter.

### Key Features

- **Complete Conversion**: Converts SMDB files to standard DAT format with proper XML structure
- **Hash Preservation**: Maintains SHA-1, MD5, and CRC checksums for accurate ROM verification
- **Game Organization**: Properly groups ROMs by game folders for better management
- **Special Character Handling**: Correctly handles special characters and XML escaping
- **Batch Processing**: Process entire directories of SMDB files at once
- **Detailed Logging**: Comprehensive logging of the conversion process
- **Error Recovery**: Robust error handling with recovery mechanisms for invalid XML
- **File Size Estimation**: Provides file size estimates when not available in SMDB

### Compatibility

The generated DAT files are compatible with:
- ROMVault
- ClrMamePro
- RomCenter
- Other tools that support the standard Logiqx XML DAT format

## Prerequisites

- **Windows** operating system (Windows 10 or higher recommended)
- **PowerShell 7.0 or higher** (the script uses features not available in Windows PowerShell 5.1)
- **Source SMDB files** to convert (typically .txt files with hash information)

No admin privileges are required for this script as it only performs file reading/writing operations.

## Installation

### Option 1: Git Clone (Recommended)

1. Clone this repository:
   ```powershell
   git clone https://github.com/yourusername/smdb-to-dat-converter.git
   cd smdb-to-dat-converter
   ```

### Option 2: Direct Download

1. Download the script file directly:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/smdb-to-dat-converter/main/Convert-SMDBtoDAT.ps1" -OutFile "$env:USERPROFILE\Convert-SMDBtoDAT.ps1"
   ```

### Option 3: Manual Installation

1. Download the [Convert-SMDBtoDAT.ps1](./Convert-SMDBtoDAT.ps1) script from this repository
2. Save it to a location of your choice

## Usage

### Basic Usage

Run the script with the source and output directories:

```powershell
# Navigate to the script location (if using the git clone method)
cd path\to\smdb-to-dat-converter

# Run the script with default parameters
.\Convert-SMDBtoDAT.ps1

# Run with custom source and output directories
.\Convert-SMDBtoDAT.ps1 -SourceDirectory "E:\SMDB-Files" -OutputDirectory "E:\DAT-Files"
```

The script will recursively find all .txt files in the source directory, process them as SMDB files, and create corresponding DAT files in the output directory while maintaining the folder structure.

### Parameters

```powershell
.\Convert-SMDBtoDAT.ps1 [parameters]

# Available parameters
# -SourceDirectory  : Directory containing SMDB files (default: E:\@Hardware-Target-Game-Database)
# -OutputDirectory  : Directory where DAT files will be created (default: E:\ROMVault-DATs)
# -LogFile          : Custom log file path (default: $env:USERPROFILE\Logs\SMDB-to-DAT_[timestamp].log)
```

### Example Scenarios

#### Convert a Single SMDB File

```powershell
# Navigate to the directory containing your SMDB file
cd C:\MyROMsDir

# Run the script for a single file
Get-Item .\MySystem.txt | ForEach-Object { 
    .\path\to\Convert-SMDBtoDAT.ps1 -SourceDirectory $_.Directory -OutputDirectory ".\DAT-Output" 
}
```

#### Process Multiple SMDB Collections

```powershell
# Process multiple source directories
$collections = @(
    "E:\EverDrive-SMDB-Files", 
    "E:\MiSTer-SMDB-Files"
)

foreach ($collection in $collections) {
    .\Convert-SMDBtoDAT.ps1 -SourceDirectory $collection -OutputDirectory "E:\Combined-DAT-Files"
}
```

#### Scheduled Conversion

You can set up a scheduled task to run this script periodically:

1. Create a script to run the conversion (e.g., `Run-Conversion.ps1`):
   ```powershell
   # Run-Conversion.ps1
   $logFile = Join-Path $env:USERPROFILE "Logs\Scheduled-SMDB-DAT-$(Get-Date -Format 'yyyyMMdd').log"
   & "C:\path\to\Convert-SMDBtoDAT.ps1" -SourceDirectory "E:\SMDB-Files" -OutputDirectory "E:\DAT-Files" -LogFile $logFile
   ```

2. Set up a scheduled task to run this script:
   - Program/script: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\Run-Conversion.ps1"`

## Features in Detail

### SMDB Format Support

The script supports SMDB files with the following format:
```
[SHA256 hash]  [file path]  [SHA1 hash]  [MD5 hash]  [CRC32 hash]
```

Example SMDB entry:
```
11a486ccc36d81d435d97d50331cebbe7d62e3cfcdd582fed6e5c5b7cc5e0607	Analogue Nt Mini Legacy/A2600/1 US - A-M/3-D Tic-Tac-Toe (USA).a26	21d983f2f52b84c22ecae84b0943678ae2c31c10	0db4f4150fecf77e4ce72ca4d04c052f	58805709
```

### DAT Format Generation

The script

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

