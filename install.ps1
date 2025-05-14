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
$BinaryPath = Join-Path $InstallPath "andasy.exe"
$TempDownload = Join-Path $env:TEMP "andasy-cli-new.exe"
$UpdateScript = Join-Path $env:TEMP "andasy-update.ps1"

if (!(Test-Path -Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

try {
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$CliRepo/releases/latest"
    $AssetUrl = $ReleaseInfo.assets | Where-Object { $_.name -match "windows-$Arch" } | Select-Object -ExpandProperty browser_download_url

    if (!$AssetUrl) {
        throw "No matching asset found for Windows $Arch"
    }

    Invoke-WebRequest -Uri $AssetUrl -OutFile $TempDownload -UseBasicParsing

    # Create update handoff script
    $UpdateScriptContent = @"
Start-Sleep -Seconds 2
\$binary = "$BinaryPath"
\$newBinary = "$TempDownload"

# Wait until the original binary is unlocked
while (\$(Test-Path \$binary -PathType Leaf) -and (Get-Process | Where-Object { \$_.Path -eq \$binary })) {
    Start-Sleep -Milliseconds 500
}

Copy-Item \$newBinary \$binary -Force
Remove-Item \$newBinary -ErrorAction SilentlyContinue
Write-Host "Andasy CLI has been updated."
& "\$binary" version
"@

    Set-Content -Path $UpdateScript -Value $UpdateScriptContent -Encoding UTF8

    # Launch update script in new PowerShell process
    Start-Process powershell -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$UpdateScript`""

    Write-Host "Andasy CLI update initiated. Please wait a moment..."
    Write-Host "Your terminal may briefly restart the binary if you run it again."

} catch {
    Write-Error "Failed to download or update Andasy CLI: $_"
    exit 1
}

# Optional: Do NOT call `andasy.exe` here — it's being updated!
Write-Host "`nPlease restart your terminal to ensure PATH updates take effect."
