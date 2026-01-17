# Python Installer for Windows
# Requires Administrator privileges

#Requires -RunAsAdministrator

# Colored output function
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Function to install Python
function Install-Python {
    param(
        [string]$Version,
        [string]$Architecture = "amd64"
    )
    
    Write-ColorOutput Yellow "Installing Python $Version ($Architecture)..."
    
    # Download URL
    $url = "https://www.python.org/ftp/python/$Version/python-$Version-$Architecture.exe"
    $installerPath = "$env:TEMP\python-$Version-installer.exe"
    
    try {
        # Download installer
        Write-Host "Downloading from $url..."
        Invoke-WebRequest -Uri $url -OutFile $installerPath -ErrorAction Stop
        
        # Installation parameters
        $installArgs = @(
            "/quiet",
            "InstallAllUsers=1",
            "PrependPath=1",
            "Include_test=0",
            "Include_pip=1",
            "Include_tcltk=1",
            "Include_doc=0",
            "Include_launcher=1",
            "InstallLauncherAllUsers=1"
        )
        
        # Run installer
        Write-Host "Installing Python $Version..."
        Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -NoNewWindow
        
        # Clean up
        Remove-Item $installerPath -Force
        
        Write-ColorOutput Green "[OK] Python $Version installed successfully!"
        
    } catch {
        Write-ColorOutput Red "[ERROR] Failed to install Python $Version"
        Write-Host $_.Exception.Message
    }
}

# Main menu
Write-ColorOutput Cyan @"
================================================
    Python Installer for Windows
================================================
"@

Write-Host "`nSelect Python version to install:"
Write-Host "1. Python 3.11.9 (latest stable 3.11)"
Write-Host "2. Python 3.12.7 (latest stable 3.12)"
Write-Host "3. Python 3.13.1 (newest version)"
Write-Host "4. Python 3.10.11 (older stable)"
Write-Host "5. Install ALL versions (3.10, 3.11, 3.12, 3.13)"
Write-Host "6. Custom version"
Write-Host "0. Exit"

$choice = Read-Host "`nYour choice"

switch ($choice) {
    "1" {
        Install-Python -Version "3.11.9"
    }
    "2" {
        Install-Python -Version "3.12.7"
    }
    "3" {
        Install-Python -Version "3.13.1"
    }
    "4" {
        Install-Python -Version "3.10.11"
    }
    "5" {
        Write-ColorOutput Cyan "`nInstalling all Python versions..."
        Install-Python -Version "3.10.11"
        Install-Python -Version "3.11.9"
        Install-Python -Version "3.12.7"
        Install-Python -Version "3.13.1"
    }
    "6" {
        $customVersion = Read-Host "Enter version number (e.g., 3.11.5)"
        Install-Python -Version $customVersion
    }
    "0" {
        Write-Host "Exiting..."
        exit
    }
    default {
        Write-ColorOutput Red "Invalid choice!"
        exit
    }
}

# Check installed versions
Write-Host "`n"
Write-ColorOutput Cyan "Checking installed Python versions:"
Write-Host "==========================================="

# Search for all installed Python versions
$pythonPaths = @(
    "C:\Program Files\Python*",
    "C:\Program Files (x86)\Python*",
    "$env:LOCALAPPDATA\Programs\Python\Python*"
)

foreach ($path in $pythonPaths) {
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $pythonExe = Join-Path $_.FullName "python.exe"
        if (Test-Path $pythonExe) {
            $version = & $pythonExe --version 2>&1
            Write-ColorOutput Green "[OK] $version - $($_.FullName)"
        }
    }
}

Write-Host "`n"
Write-ColorOutput Yellow "TIP: To use a specific Python version:"
Write-Host "- Use 'py -3.11' for Python 3.11"
Write-Host "- Or specify full path to python.exe"

Read-Host "`nPress Enter to exit"
