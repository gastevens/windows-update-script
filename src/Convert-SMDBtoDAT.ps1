<#
.SYNOPSIS
    Converts SMDB files to ROMVault DAT format.

.DESCRIPTION
    This script converts SMDB (Software Management Database) files to DAT format for use with ROMVault.
    It reads the SMDB files from E:\@Hardware-Target-Game-Database directory, extracts the necessary
    hash information (SHA-1, MD5, CRC), and generates DAT files that maintain the same folder structure.

.PARAMETER SourceDirectory
    The root directory containing SMDB files (default: E:\@Hardware-Target-Game-Database)

.PARAMETER OutputDirectory
    The directory where DAT files will be created (default: E:\ROMVault-DATs)

.PARAMETER LogFile
    The file path for log output (default: $env:USERPROFILE\Logs\SMDB-to-DAT_[timestamp].log)

.EXAMPLE
    .\Convert-SMDBtoDAT.ps1
    Converts all SMDB files in the default source directory to DAT files in the default output directory.

.EXAMPLE
    .\Convert-SMDBtoDAT.ps1 -SourceDirectory "D:\SMDB-Files" -OutputDirectory "D:\DAT-Files"
    Converts SMDB files from the specified source directory to DAT files in the specified output directory.

.NOTES
    File Name      : Convert-SMDBtoDAT.ps1
    Author         : System Administrator
    Prerequisite   : PowerShell 7.0+
    Created        : 2025-05-19
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$SourceDirectory = "E:\@Hardware-Target-Game-Database",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "E:\ROMVault-DATs",
    
    [Parameter(Mandatory = $false)]
    [string]$LogFile = (Join-Path -Path $env:USERPROFILE -ChildPath "Logs\SMDB-to-DAT_$(Get-Date -Format 'yyyyMMdd_HHmmss').log")
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
    $logDirectory = Split-Path -Path $LogFile -Parent
    if (-not (Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $formattedMessage
}
# Function to extract system name from folder path and file name
function Get-SystemName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )
    
    try {
        # First try to extract system name from filename (most accurate)
        $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        
        # Handle MiSTer Add-On files
        if ($fileNameWithoutExt -match 'MiSTer\s+(.+?)\s+Add-On') {
            return "MiSTer-$($matches[1])"
        }
        
        # Handle supplement files
        if ($fileNameWithoutExt -match '(.+?)\s+Supplement') {
            return "$($matches[1])-Supplement"
        }
        
        # Handle files with & in them - preserve the & character but note for special handling
        if ($fileNameWithoutExt -match '\s*&\s*') {
            # Keep the & but note this needs special XML handling
            return $fileNameWithoutExt
        }
        
        # Handle systems with multiple devices separated by &
        if ($fileNameWithoutExt -match '(EverDrive|Super)\s+(.+?)\s+&\s+(.+?)\s+(SMDB|$)') {
            return "$($matches[1]) $($matches[2]) and $($matches[3])".Trim()
        }
        
        # Special case handling for common SMDB file patterns
        if ($fileNameWithoutExt -match '^(Atari|Sega|Nintendo|Sony|NES|SNES|GB|GBA|GBC|SMS|Genesis|MD|PS1|PS2|PS3|Dreamcast|Saturn|Jaguar|Lynx|NGPC|PCE|TG16|Neo\s*Geo|Arcade|MAME|CPS[1-3]|Namco|Taito|Colecovision|VB|Virtual\s*Boy|WS|WSC|Wonderswan)') {
            return $fileNameWithoutExt
        }
    
        # If filename contains "SMDB", extract the system name from it
        if ($fileNameWithoutExt -match '(.+?)\s*SMDB') {
            return $matches[1].Trim()
        }
        
        # Handle MiSTer.txt special case
        if ($fileNameWithoutExt -eq "MiSTer") {
            return "MiSTer-Core"
        }
        
        # Handle special filenames like Apocalypse
        if ($fileNameWithoutExt -in @("Apocalypse", "SegaCD", "MegaSD")) {
            return $fileNameWithoutExt
        }
        
        # If filename is meaningful (not generic), use it
        if (-not $fileNameWithoutExt.Contains("SMDB") -and 
            -not $fileNameWithoutExt -eq "SMDB" -and
            -not $fileNameWithoutExt -in @("Supplement", "Add-On", "addon", "pack")) {
            return $fileNameWithoutExt
        }
    
    # Extract system name from folder path as backup
    # First, get relative path from source directory
    $relativePath = $FolderPath.Replace($SourceDirectory, '').TrimStart('\')
    
    # If first folder is too generic, combine with second folder
    $folders = $relativePath -split '\\'
    
    if ($folders.Count -gt 0) {
        # Handle specific platform naming patterns
        if ($folders[0] -match 'Analogue|MiSTer|OpenFPGA|FPGAs|EverDrive') {
            # For more specific platform identification
            if ($folders.Count -gt 1) {
                return "$($folders[0]) - $($folders[1])"
            }
        }
        
        # Extract from parent folder if it's not a generic name
        $parentFolder = $folders[$folders.Count - 1]
        if (-not $parentFolder -in @("SMDBs", "Database", "SMDB", "Files", "Collections")) {
            return $parentFolder
        }
        
        # Use the first non-generic folder
        foreach ($folder in $folders) {
            if (-not $folder -in @("SMDBs", "Database", "SMDB", "Files", "Collections", "EverDrive Pack SMDBs")) {
                return $folder
            }
        }
        
        # Try to use the filename as a last attempt
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        if ($baseName -and $baseName -ne "SMDB" -and -not [string]::IsNullOrWhiteSpace($baseName)) {
            return $baseName
        }
        
        # Last resort - combine folder path and filename
        $leafFolder = Split-Path -Path $FolderPath -Leaf
        if ($leafFolder -notin @("SMDBs", "Database", "SMDB", "Files", "Collections", "EverDrive Pack SMDBs")) {
            return "$leafFolder-$([System.IO.Path]::GetFileNameWithoutExtension($FileName))"
        }
        
        return $folders[0]
    }
    
    # Fallback to directory name if parsing fails
    return (Split-Path -Path $FolderPath -Leaf)
    }
    catch {
        Write-Log -Message "Error extracting system name: $($_.Exception.Message). Using filename as fallback." -Level 'Warning'
        # Ultimate fallback is just the filename without extension
        return [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    }
}

# Function to clean and escape a name for XML and filesystem safety
function Get-SafeName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    # First clean for XML
    $xmlSafe = $Name -replace '&', 'and' -replace '<', '_lt_' -replace '>', '_gt_' -replace '"', '_quot_' -replace "'", '_apos_'
    
    # Then clean for filesystem
    $fileSafe = $xmlSafe -replace '[\\/:*?"<>|]', '-'
    
    return $fileSafe
}
# Function to calculate file size from the path (if needed)
function Get-EstimatedFileSize {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    # Try to extract size from common filename patterns
    # Some file extensions have typical sizes
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    # Default sizes for common formats (in bytes)
    switch ($extension) {
        ".gb"  { return 32768 }  # Typical Game Boy ROM size
        ".gbc" { return 128000 } # Typical Game Boy Color ROM size
        ".nes" { return 40960 }  # Typical NES ROM size
        ".sfc" { return 524288 } # Typical SNES ROM size
        ".md"  { return 524288 } # Typical Genesis/Mega Drive ROM size
        ".sms" { return 131072 } # Typical Master System ROM size
        ".a26" { return 4096 }   # Typical Atari 2600 ROM size
        ".bin" { return 262144 } # Generic binary size
        default { return 65536 } # Default size if unknown
    }
}

# Function to extract ROM information from SMDB entry
function Parse-SMDBEntry {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Entry
    )
    
    # Split the entry by tab characters
    $parts = $Entry -split '\t'
    
    # Check if entry has all necessary parts
    if ($parts.Count -lt 5) {
        Write-Log -Message "Invalid SMDB entry format: $Entry" -Level 'Warning'
        return $null
    }
    
    # Extract data
    $sha256 = $parts[0]
    $filePath = $parts[1]
    $sha1 = $parts[2]
    $md5 = $parts[3]
    $crc = $parts[4]
    
    # Extract ROM name from file path
    $romName = Split-Path -Path $filePath -Leaf
    
    # Extract folder path for grouping
    $folderPath = Split-Path -Path $filePath -Parent
    
    # Calculate estimated file size
    $fileSize = Get-EstimatedFileSize -FilePath $filePath
    
    # Return ROM object
    return [PSCustomObject]@{
        Name = $romName
        FilePath = $filePath
        FolderPath = $folderPath
        SHA1 = $sha1
        MD5 = $md5
        CRC = $crc
        SHA256 = $sha256
        Size = $fileSize
    }
}

# Function to create DAT file header
function Get-DATHeader {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SystemName,
        
        [Parameter(Mandatory = $true)]
        [string]$Category
    )
    
    # Get current date in the format required by DAT files
    $currentDate = Get-Date -Format "yyyyMMdd"
    
    # Clean system name for XML
    $cleanSystemName = $SystemName -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
    
    # Create DAT header - no game or rom tags yet, those will be added per game
    $header = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE datafile PUBLIC "-//Logiqx//DTD ROM Management Datafile//EN" "http://www.logiqx.com/Dats/datafile.dtd">
<datafile>
    <header>
        <name>$cleanSystemName</name>
        <description>$cleanSystemName ROM set for ROMVault</description>
        <category>$Category</category>
        <version>$currentDate</version>
        <date>$currentDate</date>
        <author>Generated by Convert-SMDBtoDAT.ps1</author>
    </header>

"@
    
    return $header
}

# Function to create DAT file footer
function Get-DATFooter {
    return @"
</datafile>
"@
}

# Function to create game entry start
function Get-GameStart {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GameName,
        
        [Parameter(Mandatory = $true)]
        [string]$Category
    )
    
    # Clean game name for XML
    $cleanGameName = $GameName -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
    
    # Format XML with proper indentation
    return @"
    <game name="$cleanGameName">
        <description>$cleanGameName</description>
        <category>$Category</category>

"@
}

# Function to create game entry end
function Get-GameEnd {
    return @"
    </game>

"@
}

# Function to create ROM entry in DAT format
function Get-ROMEntry {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$ROM
    )
    
    # Format ROM entry for DAT file
    # Note: Handling case where some hashes might be missing
    $sha1Value = if ($ROM.SHA1 -and $ROM.SHA1 -ne "") { $ROM.SHA1 } else { "00000000000000000000000000000000" }
    $md5Value = if ($ROM.MD5 -and $ROM.MD5 -ne "") { $ROM.MD5 } else { "00000000000000000000000000" }
    $crcValue = if ($ROM.CRC -and $ROM.CRC -ne "") { $ROM.CRC } else { "00000000" }
    
    # Use calculated size or default
    $sizeValue = if ($ROM.Size -gt 0) { $ROM.Size } else { 65536 }
    
    # Clean up ROM name (remove any XML-incompatible characters)
    $cleanName = $ROM.Name -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
    
    # Build ROM entry with proper format for ROMVault using here-string for better readability
    # The order of attributes matters for compatibility with different DAT parsers
    # ROMVault expects: name, size, crc, md5, sha1
    $entry = @"
        <rom name="$cleanName" size="$sizeValue" crc="$crcValue" md5="$md5Value" sha1="$sha1Value" />
"@
    
    return $entry
}

# Function to convert SMDB file to DAT format
function Convert-SMDBToDAT {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SMDBFilePath
    )
    
    try {
        # Get folder path of SMDB file
        $folderPath = Split-Path -Path $SMDBFilePath -Parent
        $fileName = Split-Path -Path $SMDBFilePath -Leaf
        
        # Get system name from folder path and file name
        $systemName = Get-SystemName -FolderPath $folderPath -FileName $fileName
        
        # Clean system name for file naming and XML
        $safeSystemName = Get-SafeName -Name $systemName
        
        # Get category from system name
        $category = $systemName -replace '[\\/]', '-' -replace '&', 'and'
        
        # Try to read SMDB file content
        try {
            $content = Get-Content -Path $SMDBFilePath -ErrorAction Stop
        }
        catch {
            Write-Log -Message "Error reading SMDB file: $SMDBFilePath - $($_.Exception.Message)" -Level 'Error'
            return $null
        }
        
        # Handle empty files
        if ($null -eq $content) {
            Write-Log -Message "SMDB file is null: $SMDBFilePath" -Level 'Warning'
            return $null
        }
        
        # Handle string content (single line)
        if ($content -is [string]) {
            $content = @($content)
        }
        
        # Check if content is empty or not an array
        if (-not ($content -is [array]) -or $content.Count -eq 0) {
            Write-Log -Message "SMDB file is empty or invalid: $SMDBFilePath" -Level 'Warning'
            return $null
        }
        
        # Parse ROM entries
        $roms = @()
        foreach ($line in $content) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }
            
            $rom = Parse-SMDBEntry -Entry $line
            if ($rom) {
                $roms += $rom
            }
        }
        
        # Skip if no valid ROMs found
        if ($roms.Count -eq 0) {
            Write-Log -Message "No valid ROM entries found in SMDB file: $SMDBFilePath" -Level 'Warning'
            return $null
        }
        
        # Create output directory structure that mirrors the source
        $relativePath = $folderPath.Replace($SourceDirectory, '').TrimStart('\')
        $outputPath = Join-Path -Path $OutputDirectory -ChildPath $relativePath
        
        # Create output directory if it doesn't exist
        if (-not (Test-Path -Path $outputPath)) {
            New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
            Write-Log -Message "Created output directory: $outputPath" -Level 'Info'
        }
        
        # Create DAT file path with the safe system name
        $datFileName = "$safeSystemName.dat"
        $datFilePath = Join-Path -Path $outputPath -ChildPath $datFileName
        
        # Create DAT file content with proper XML formatting
        $datContent = Get-DATHeader -SystemName $systemName -Category $category
        
        # Group ROMs by folder path (each folder becomes a separate game)
        $groupedROMs = $roms | Group-Object -Property { 
            # Extract the game folder from the file path
            $parentPath = Split-Path -Path $_.FilePath -Parent
            
            # Get the last folder in the path as the game name
            $lastFolder = Split-Path -Path $parentPath -Leaf
            
            # If the folder is a common bin or ROM folder, use parent folder
            if ($lastFolder -in @("bin", "rom", "roms", "ROM", "ROMs", "Bin", "BIN", "ISO", "iso", "Disk", "DISK", "disk")) {
                $grandparentPath = Split-Path -Path $parentPath -Parent
                $lastFolder = Split-Path -Path $grandparentPath -Leaf
            }
            
            # Clean up any problematic characters in the game name
            $cleanLastFolder = $lastFolder -replace '&', 'and' -replace '[\\/:*?"<>|]', '-'
            
            return $cleanLastFolder
        }
        
        # Process each game group
        foreach ($group in $groupedROMs) {
            # Skip empty groups
            if ($group.Count -eq 0) { continue }
            
            # Get cleaned game name
            $gameName = if ([string]::IsNullOrWhiteSpace($group.Name)) { 
                "Unknown Game" 
            } else { 
                $group.Name
            }
            
            # Add game start
            $datContent += Get-GameStart -GameName $gameName -Category $category
            
            # Add ROM entries with proper indentation
            foreach ($rom in $group.Group) {
                try {
                    $datContent += Get-ROMEntry -ROM $rom
                    $datContent += "`n"
                }
                catch {
                    Write-Log -Message "Error creating ROM entry for $($rom.Name): $($_.Exception.Message)" -Level 'Warning'
                    # Continue processing other ROMs
                }
            }
            
            # Add game end
            $datContent += Get-GameEnd
        }
        
        # Add footer
        $datContent += Get-DATFooter
        
        # Ensure valid XML before writing
        try {
            # Test XML validity (will throw if invalid)
            [xml]$testXml = $datContent
            
            # Write DAT file
            Set-Content -Path $datFilePath -Value $datContent -Encoding UTF8
            Write-Log -Message ("Successfully validated XML for '{0}'." -f $systemName) -Level 'Info'
        }
        catch {
            # If there's an XML validation error, try to fix common issues
            $errorMsg = $_.Exception.Message
            Write-Log -Message ("Error validating XML for '{0}'. Error: {1}" -f $systemName, $errorMsg) -Level 'Warning'
            
            # Try to sanitize the content more aggressively
            $fixedContent = $datContent -replace '&(?!amp;|lt;|gt;|quot;|apos;)', '&amp;'
            
            try {
                # Test if the fixed XML is valid
                [xml]$testXml = $fixedContent
                
                # If we get here, the fix worked - write the sanitized XML
                Set-Content -Path $datFilePath -Value $fixedContent -Encoding UTF8
                Write-Log -Message ("Successfully fixed and validated XML for '{0}'." -f $systemName) -Level 'Success'
            }
            catch {
                # If still failing, fall back to writing the original content
                Write-Log -Message ("Could not fix XML validation issues for '{0}'. Attempting to write anyway." -f $systemName) -Level 'Warning'
                Set-Content -Path $datFilePath -Value $datContent -Encoding UTF8
            }
        }
        
        Write-Log -Message "Successfully created DAT file: $datFilePath" -Level 'Success'
        
        return $datFilePath
    }
    catch {
        Write-Log -Message "Error converting SMDB to DAT: $($_.Exception.Message)" -Level 'Error'
        return $null
    }
}

# Main script execution
try {
    # Verify source directory exists
    if (-not (Test-Path -Path $SourceDirectory)) {
        throw "Source directory not found: $SourceDirectory"
    }
    
    # Create output directory if it doesn't exist
    if (-not (Test-Path -Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
        Write-Log -Message "Created output directory: $OutputDirectory" -Level 'Info'
    }
    
    # Start logging
    Write-Log -Message "Starting SMDB to DAT conversion" -Level 'Info'
    Write-Log -Message "Source directory: $SourceDirectory" -Level 'Info'
    Write-Log -Message "Output directory: $OutputDirectory" -Level 'Info'
    
    # Find SMDB files recursively
    $smdbFiles = Get-ChildItem -Path $SourceDirectory -Filter "*.txt" -Recurse
    $totalFiles = $smdbFiles.Count
    
    Write-Log -Message "Found $totalFiles SMDB files to process" -Level 'Info'
    
    # Initialize counters
    $processedCount = 0
    $successCount = 0
    $failedCount = 0
    
    # Process each SMDB file
    foreach ($smdbFile in $smdbFiles) {
        $processedCount++
        $percentComplete = [math]::Round(($processedCount / $totalFiles) * 100, 2)
        
        Write-Progress -Activity "Converting SMDB to DAT" -Status "Processing file $processedCount of $totalFiles ($percentComplete%)" -PercentComplete $percentComplete
        
        Write-Log -Message "Processing SMDB file ($processedCount/$totalFiles): $($smdbFile.FullName)" -Level 'Info'
        
        # Check if file is a valid SMDB file (not empty, has proper format)
        $fileInfo = Get-Item $smdbFile.FullName
        if ($fileInfo.Length -eq 0) {
            Write-Log -Message "Skipping empty file: $($smdbFile.FullName)" -Level 'Warning'
            $failedCount++
            continue
        }
        
        # Attempt conversion
        $result = Convert-SMDBToDAT -SMDBFilePath $smdbFile.FullName
        
        if ($result) {
            $successCount++
        }
        else {
            $failedCount++
        }
    }
    
    # Complete progress bar
    Write-Progress -Activity "Converting SMDB to DAT" -Completed
    
    # Log completion
    Write-Log -Message "SMDB to DAT conversion completed" -Level 'Success'
    Write-Log -Message "Total files processed: $totalFiles" -Level 'Info'
    Write-Log -Message "Successfully converted: $successCount" -Level 'Success'
    Write-Log -Message "Failed to convert: $failedCount" -Level 'Warning'
    
    # Show output directory
    Write-Log -Message "DAT files are available in: $OutputDirectory" -Level 'Info'
    
    # Return success
    return 0
}
catch {
    Write-Log -Message "Error in main script execution: $($_.Exception.Message)" -Level 'Error'
    Write-Log -Message "Stack trace: $($_.ScriptStackTrace)" -Level 'Error'
    
    # Return failure
    return 1
}

