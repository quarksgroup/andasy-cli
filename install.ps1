param(
    [string]$CliRepo = "quarksgroup/andasy-cli"
)

# Rest of the PowerShell script remains the same as in the previous version
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

if (!(Test-Path -Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$NewPath = ($CurrentPath -split ';' | Where-Object { $_ -ne $InstallPath }) -join ';'
[Environment]::SetEnvironmentVariable("Path", $NewPath, "User")

try {
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$CliRepo/releases/latest"
    $AssetUrl = $ReleaseInfo.assets | 
        Where-Object { $_.name -match "windows-$Arch" } | 
        Select-Object -ExpandProperty browser_download_url

    if (!$AssetUrl) {
        throw "No matching asset found for Windows $Arch"
    }

    $TempFile = Join-Path $env:TEMP "andasy-cli.zip"
    Invoke-WebRequest -Uri $AssetUrl -OutFile $TempFile
    Expand-Archive -Path $TempFile -DestinationPath $InstallPath -Force
    Remove-Item $TempFile
} catch {
    Write-Error "Failed to download and install Andasy CLI: $_"
    exit 1
}

$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$InstallPath*") {
    [Environment]::SetEnvironmentVariable(
        "Path", 
        "$CurrentPath;$InstallPath", 
        "User"
    )
}

$AndasyVersion = & "$InstallPath\andasy.exe" version

Write-Host "Andasy CLI has been installed to $InstallPath"
Write-Host "$AndasyVersion"
Write-Host "`nPlease restart your terminal to ensure PATH updates take effect."