param(
    [string]$CliRepo = "quarksgroup/andasy-cli"
)

$ErrorActionPreference = "Stop"  # Exit on any error

# Cleanup function for temp files
function Remove-TempFiles {
    param([string]$TempFile, [string]$TempDir)
    
    if ($TempFile -and (Test-Path $TempFile)) {
        Remove-Item -Path $TempFile -Force -ErrorAction SilentlyContinue
    }
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "Error: PowerShell 5.0 or higher is required" -ForegroundColor Red
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    exit 1
}

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
$BackupExePath = "$InstallPath\andasy.backup.exe"
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

$TempFile = $null
$TempDir = $null

try {
    # Download the latest release
    Write-Host "Downloading Andasy CLI..." -ForegroundColor Cyan
    
    try {
        $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$CliRepo/releases/latest"
    } catch {
        Write-Host "Error: Failed to fetch release information from GitHub" -ForegroundColor Red
        Write-Host "$_" -ForegroundColor Red
        exit 1
    }
    
    $AssetUrl = $ReleaseInfo.assets |
        Where-Object { $_.name -match "windows-$Arch" } |
        Select-Object -ExpandProperty browser_download_url -First 1

    if (!$AssetUrl) {
        Write-Host "Error: No matching asset found for Windows $Arch" -ForegroundColor Red
        Write-Host "Please visit https://github.com/$CliRepo/releases for manual installation" -ForegroundColor Yellow
        exit 1
    }

    $TempFile = Join-Path $env:TEMP "andasy-cli-$(Get-Random).zip"
    
    try {
        Invoke-WebRequest -Uri $AssetUrl -OutFile $TempFile
    } catch {
        Write-Host "Error: Failed to download CLI binary" -ForegroundColor Red
        Write-Host "$_" -ForegroundColor Red
        Remove-TempFiles -TempFile $TempFile
        exit 1
    }

    Write-Host "Installing to $InstallPath..." -ForegroundColor Cyan
    $TempDir = Join-Path $env:TEMP "andasy-extract-$(Get-Random)"
    
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

    try {
        Expand-Archive -Path $TempFile -DestinationPath $TempDir -Force
    } catch {
        Write-Host "Error: Failed to extract CLI binary" -ForegroundColor Red
        Write-Host "$_" -ForegroundColor Red
        Remove-TempFiles -TempFile $TempFile -TempDir $TempDir
        exit 1
    }
    
    Remove-Item $TempFile -Force
    $TempFile = $null

    $ExtractedExe = "$TempDir\andasy.exe"
    if (!(Test-Path $ExtractedExe)) {
        Write-Host "Error: Extracted archive does not contain andasy.exe" -ForegroundColor Red
        Remove-TempFiles -TempDir $TempDir
        exit 1
    }

    # Verify the downloaded binary works
    Write-Host "Verifying downloaded binary..." -ForegroundColor Cyan
    try {
        $TestVersion = & "$ExtractedExe" version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Binary verification failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Host "Error: Downloaded binary is not functional" -ForegroundColor Red
        Write-Host "$_" -ForegroundColor Red
        Remove-TempFiles -TempDir $TempDir
        exit 1
    }

    Copy-Item -Path $ExtractedExe -Destination $NewExePath -Force

    if ($isUpdate) {
        Write-Host "Update downloaded and verified." -ForegroundColor Green
        Write-Host "Preparing to apply update..." -ForegroundColor Cyan

        # Create backup of current version (required for rollback on failure)
        try {
            Copy-Item -Path $ExePath -Destination $BackupExePath -Force -ErrorAction Stop
        } catch {
            Write-Error "Backup failed: could not copy '$ExePath' to '$BackupExePath'. $_"
            Remove-TempFiles -TempDir $TempDir
            exit 1
        }

        $batchContent = @"
@echo off
setlocal enabledelayedexpansion

echo Applying Andasy CLI update...
timeout /t 2 /nobreak >nul

set max_attempts=30
set attempt=0

:retry
set /a attempt+=1

REM Try to delete the old executable
del "$ExePath" 2>nul
if exist "$ExePath" (
    if !attempt! lss %max_attempts% (
        timeout /t 1 /nobreak >nul
        goto retry
    ) else (
        echo Update failed: Could not replace running executable
        echo Please close all instances of andasy and try again
        pause
        goto cleanup
    )
)

REM Move new version into place
move "$NewExePath" "$ExePath" >nul
if errorlevel 1 (
    echo Update failed: Could not move new executable
    REM Restore backup if available
    if exist "$BackupExePath" (
        echo Restoring backup...
        move "$BackupExePath" "$ExePath" >nul
    )
    pause
    goto cleanup
)

REM Verify the update
"$ExePath" version >nul 2>&1
if errorlevel 1 (
    echo Update failed: New version is not functional
    REM Restore backup if available
    if exist "$BackupExePath" (
        echo Restoring backup...
        del "$ExePath" 2>nul
        move "$BackupExePath" "$ExePath" >nul
    )
    pause
    goto cleanup
)

echo Update completed successfully!
REM Clean up backup
if exist "$BackupExePath" del "$BackupExePath" 2>nul

:cleanup
REM Clean up updater scripts
timeout /t 1 /nobreak >nul
if exist "$InstallPath\run-update.vbs" del "$InstallPath\run-update.vbs" 2>nul
(goto) 2>nul & del "%~f0"
"@
        $UpdaterBatchPath = "$InstallPath\update-andasy.bat"
        Set-Content -Path $UpdaterBatchPath -Value $batchContent

        $RunnerPath = "$InstallPath\run-update.vbs"
        $vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & "$UpdaterBatchPath" & Chr(34), 1, false
Set WshShell = Nothing
"@
        Set-Content -Path $RunnerPath -Value $vbsContent

        Write-Host ""
        Write-Host "Starting update process in background..." -ForegroundColor Cyan
        Write-Host "A command window will appear briefly to complete the update." -ForegroundColor Gray
        Start-Process -FilePath "wscript.exe" -ArgumentList "`"$RunnerPath`"" -WindowStyle Hidden

        Write-Host ""
        Write-Host "Update will be applied automatically." -ForegroundColor Green
        Write-Host "You can continue using the current version until the update completes." -ForegroundColor Gray

    } else {
        # Fresh installation
        Move-Item -Path $NewExePath -Destination $ExePath -Force

        $wrapperContent = @"
@echo off
REM This is a wrapper script for andasy.exe that enables self-updating
"%~dp0andasy.exe" %*
"@
        Set-Content -Path $BatchPath -Value $wrapperContent

        Write-Host "Verifying installation..." -ForegroundColor Cyan
        try {
            $VersionOutput = & "$ExePath" version 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Verification failed with exit code $LASTEXITCODE"
            }
            Write-Host ""
            Write-Host "✓ Installation successful!" -ForegroundColor Green
            Write-Host "Version: $($VersionOutput -replace '^andasy\s+', '')" -ForegroundColor Cyan
        } catch {
            Write-Host ""
            Write-Host "Warning: Installation completed but CLI verification failed" -ForegroundColor Yellow
            Write-Host "$_" -ForegroundColor Yellow
        }

        Write-Host ""
        if ($PathUpdated) {
            Write-Host "PATH updated successfully" -ForegroundColor Green
            Write-Host "  New PowerShell/CMD windows can use 'andasy' immediately" -ForegroundColor Gray
            Write-Host "  VS Code users: Please restart VS Code to access 'andasy' in integrated terminals" -ForegroundColor Yellow
        } else {
            Write-Host "PATH already configured" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "🚀 Get started with: andasy --help" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To uninstall, run:" -ForegroundColor Cyan
        Write-Host "  Remove-Item -Recurse -Force '$env:USERPROFILE\.andasy'" -ForegroundColor Gray
        Write-Host "  (and manually remove '$InstallPath' from your PATH)" -ForegroundColor Gray
    }

    # Clean up temp directory
    Remove-TempFiles -TempDir $TempDir

} catch {
    Write-Host ""
    Write-Host "Error: Failed to install Andasy CLI" -ForegroundColor Red
    Write-Host "$_" -ForegroundColor Red
    
    # Clean up on error
    Remove-TempFiles -TempFile $TempFile -TempDir $TempDir
    
    # Remove partial installation
    if (Test-Path $NewExePath) {
        Remove-Item -Path $NewExePath -Force -ErrorAction SilentlyContinue
    }
    
    exit 1
}