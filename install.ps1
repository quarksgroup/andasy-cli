param(
    [string]$CliRepo = "quarksgroup/andasy-cli"
)

$Arch = $env:PROCESSOR_ARCHITECTURE
switch ($Arch) {
    "AMD64" { $Arch = "amd64" }
    "ARM64" { $Arch = "arm64" }
    default {
        Write-Error "Unsupported architecture: $Arch"
        exit 1
    }
}

$InstallPath = "$env:USERPROFILE\.andasy\bin"
$ExePath = "$InstallPath\andasy.exe"
$TempDir = "$env:TEMP\andasy-update"
$TempExePath = "$TempDir\andasy.exe"

# Create temp directory if it doesn't exist
if (!(Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
}

# Create installation directory if it doesn't exist
if (!(Test-Path -Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

# Ensure installation directory is in PATH
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$InstallPath*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$InstallPath",
        "User"
    )
}

try {
    # Download the latest release
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$CliRepo/releases/latest"
    $AssetUrl = $ReleaseInfo.assets |
        Where-Object { $_.name -match "windows-$Arch" } |
        Select-Object -ExpandProperty browser_download_url
    
    if (!$AssetUrl) {
        throw "No matching asset found for Windows $Arch"
    }
    
    Write-Host "Downloading latest version..."
    $TempFile = Join-Path $env:TEMP "andasy-cli.zip"
    Invoke-WebRequest -Uri $AssetUrl -OutFile $TempFile
    
    # Extract to temporary location first
    Write-Host "Extracting files..."
    Expand-Archive -Path $TempFile -DestinationPath $TempDir -Force
    Remove-Item $TempFile
    
    # Check if the binary exists and is currently in use
    $fileInUse = $false
    if (Test-Path $ExePath) {
        try {
            # Try to open the file exclusively to check if it's locked
            $fileStream = [System.IO.File]::Open($ExePath, 'Open', 'Read', 'None')
            $fileStream.Close()
            $fileStream.Dispose()
        } catch {
            $fileInUse = $true
        }
    }
    
    if ($fileInUse) {
        # Create the replacement script
        $replacerScript = @"
Start-Sleep -Seconds 1
`$attempts = 0
`$maxAttempts = 10

while (`$attempts -lt `$maxAttempts) {
    try {
        if (Test-Path "$ExePath") {
            Remove-Item "$ExePath" -Force
        }
        Copy-Item "$TempExePath" "$ExePath" -Force
        break
    } catch {
        `$attempts++
        Start-Sleep -Seconds 1
    }
}

if (`$attempts -lt `$maxAttempts) {
    Write-Host "Andasy CLI has been successfully updated."
} else {
    Write-Host "Failed to update Andasy CLI after `$maxAttempts attempts."
}

# Clean up temp directory
Remove-Item -Path "$TempDir" -Recurse -Force -ErrorAction SilentlyContinue
"@
        
        $replacerPath = Join-Path $env:TEMP "andasy-replacer.ps1"
        Set-Content -Path $replacerPath -Value $replacerScript
        
        Write-Host "The current andasy.exe is in use. Starting update process..."
        
        # Start the replacer script in a new process
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$replacerPath`"" -WindowStyle Hidden
        
        Write-Host "Update process initiated. The CLI will be updated shortly."
        Write-Host "Please restart any terminal sessions using andasy for the changes to take effect."
    } else {
        # Directly replace the file if it's not in use
        if (Test-Path $ExePath) {
            Remove-Item $ExePath -Force
        }
        Copy-Item $TempExePath $ExePath -Force
        
        # Clean up
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        $AndasyVersion = & "$ExePath" version
        Write-Host "Andasy CLI has been updated successfully."
        Write-Host "$AndasyVersion"
    }
} catch {
    Write-Error "Failed to download and install Andasy CLI: $_"
    exit 1
}