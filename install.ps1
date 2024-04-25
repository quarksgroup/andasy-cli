$GITHUB_REPOSITORY="quarksgroup/drop-cli"

$LATEST_VERSION=Invoke-WebRequest -Uri "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json -ErrorAction Stop | Select-Object -ExpandProperty tag_name

Invoke-WebRequest -Uri "https://github.com/$GITHUB_REPOSITORY/releases/download/$LATEST_VERSION/dropctl-windows-amd64.zip" -OutFile "dropctl.zip"

New-Item -ItemType Directory -Force -Path "$env:APPDATA\dropctl" | Out-Null
		
Expand-Archive -Force -Path "dropctl.zip" -DestinationPath "$env:APPDATA\dropctl"
		
Remove-Item -Path "dropctl.zip"
		
if ($env:PATH -notlike "*$env:APPDATA\dropctl*") {
  $env:PATH += ";$env:APPDATA\dropctl"
	[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [System.EnvironmentVariableTarget]::User)
}

Write-Host "dropctl installed successfully."
