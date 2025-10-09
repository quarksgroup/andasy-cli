param(
    [string]$CliRepo = "quarksgroup/andasy-cli"
)

$ErrorActionPreference = "Stop"  # Exit on any error

$Arch = $env:PROCESSOR_ARCHITECTURE
switch ($Arch) {
    "AMD64" { $Arch = "amd64" }
    "ARM64" { $Arch = "arm64" }
    default {
        Write-Host "Error: Unsupported architecture: $Arch" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Detecting system: Windows $Arch" -ForegroundColor Cyan

$InstallPath = "$env:USERPROFILE\.andasy\bin"
$ExePath = "$InstallPath\andasy.exe"
$NewExePath = "$InstallPath\andasy.new.exe"
$BatchPath = "$InstallPath\andasy.bat"

$isUpdate = Test-Path $ExePath

# Create installation directory if it doesn't exist
if (!(Test-Path -Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

# Ensure installation directory is in PATH
$PathUpdated = $false
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$InstallPath*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$InstallPath",
        "User"
    )
    $PathUpdated = $true
    
    # Refresh PATH in current session for immediate access
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + 
                [Environment]::GetEnvironmentVariable("Path", "User")
}

try {
    # Download the latest release
    Write-Host "Downloading Andasy CLI..." -ForegroundColor Cyan
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$CliRepo/releases/latest"
    $AssetUrl = $ReleaseInfo.assets |
        Where-Object { $_.name -match "windows-$Arch" } |
        Select-Object -ExpandProperty browser_download_url

    if (!$AssetUrl) {
        Write-Host "Error: No matching asset found for Windows $Arch" -ForegroundColor Red
        Write-Host "Please visit https://github.com/$CliRepo/releases for manual installation" -ForegroundColor Yellow
        exit 1
    }

    $TempFile = Join-Path $env:TEMP "andasy-cli.zip"
    Invoke-WebRequest -Uri $AssetUrl -OutFile $TempFile

    Write-Host "Installing to $InstallPath..." -ForegroundColor Cyan
    $TempDir = Join-Path $env:TEMP "andasy-update"
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

    Expand-Archive -Path $TempFile -DestinationPath $TempDir -Force
    Remove-Item $TempFile

    # Copy the new executable to the final directory
    Copy-Item -Path "$TempDir\andasy.exe" -Destination $NewExePath -Force

    # --- Refactored Logic ---
    # Now, handle the update or new installation based on $isUpdate
    if ($isUpdate) {
        # This is an update, so use the delayed replacement method
        Write-Host "Update downloaded and ready to apply." -ForegroundColor Cyan
        Write-Host "The update will be applied automatically when possible." -ForegroundColor Gray

        # Create a batch script that will handle the replacement
        $batchContent = @"
@echo off
setlocal enabledelayedexpansion

REM Wait a moment for any running processes to exit
timeout /t 1 /nobreak >nul

REM Try to replace the file several times
set max_attempts=20
set attempt=0

:retry
set /a attempt+=1
REM Silently attempt replacement

REM Try to delete the old executable
del "$ExePath" 2>nul
if exist "$ExePath" (
    if !attempt! lss %max_attempts% (
        REM Wait and retry
        timeout /t 1 /nobreak >nul
        goto retry
    ) else (
        REM Failed but don't output anything
        goto cleanup
    )
)

REM Now move the new file into place
move "$NewExePath" "$ExePath" >nul

:cleanup
REM Remove the temporary batch file (itself)
(goto) 2>nul & del "%~f0"
"@
        $UpdaterBatchPath = "$InstallPath\update-andasy.bat"
        Set-Content -Path $UpdaterBatchPath -Value $batchContent

        # Create a delayed execution of the updater batch
        $RunnerPath = "$InstallPath\run-update.vbs"
        $vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & "$UpdaterBatchPath" & Chr(34), 0, false
Set WshShell = Nothing
"@
        Set-Content -Path $RunnerPath -Value $vbsContent

        Start-Process -FilePath "wscript.exe" -ArgumentList "`"$RunnerPath`"" -WindowStyle Hidden

    } else {
        # This is a new installation, so we can directly rename the executable
        Move-Item -Path $NewExePath -Destination $ExePath -Force

        # Create a wrapper batch file to call the executable
        # This is done for both installs and updates
        $wrapperContent = @"
@echo off
REM This is a wrapper script for andasy.exe that enables self-updating
"%~dp0andasy.exe" %*
"@
        Set-Content -Path $BatchPath -Value $wrapperContent

        # Verify installation
        Write-Host "Verifying installation..." -ForegroundColor Cyan
        try {
            $VersionOutput = & "$ExePath" version 2>&1
            Write-Host ""
            Write-Host "Installation successful!" -ForegroundColor Green
            Write-Host "Version: $VersionOutput" -ForegroundColor Cyan
        } catch {
            Write-Host "Warning: Installation completed but CLI verification failed" -ForegroundColor Yellow
        }

        # Display PATH information
        Write-Host ""
        if ($PathUpdated) {
            Write-Host "PATH updated successfully" -ForegroundColor Green
            Write-Host "New PowerShell/CMD windows can use 'andasy' immediately" -ForegroundColor Gray
            Write-Host "VS Code users: Please restart VS Code to access 'andasy' in integrated terminals" -ForegroundColor Yellow
        } else {
            Write-Host "PATH already configured" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "🚀 Get started with: andasy --help" -ForegroundColor Cyan
    }

} catch {
    Write-Host ""
    Write-Host "Error: Failed to download and install Andasy CLI" -ForegroundColor Red
    Write-Host "$_" -ForegroundColor Red
    exit 1
}
