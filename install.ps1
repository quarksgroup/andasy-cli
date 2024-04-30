$GITHUB_REPOSITORY="quarksgroup/andasy-cli"

$LATEST_VERSION=Invoke-WebRequest -Uri "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json -ErrorAction Stop | Select-Object -ExpandProperty tag_name

Invoke-WebRequest -Uri "https://github.com/$GITHUB_REPOSITORY/releases/download/$LATEST_VERSION/andasy-windows-amd64.zip" -OutFile "andasy.zip"

New-Item -ItemType Directory -Force -Path "$env:APPDATA\andasy" | Out-Null
		
Expand-Archive -Force -Path "andasy.zip" -DestinationPath "$env:APPDATA\andasy"
		
Remove-Item -Path "andasy.zip"
		
if ($env:PATH -notlike "*$env:APPDATA\andasy*") {
  $env:PATH += ";$env:APPDATA\andasy"
	[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [System.EnvironmentVariableTarget]::User)
}

Write-Host "andasy installed successfully."
