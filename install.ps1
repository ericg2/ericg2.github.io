$ErrorActionPreference = 'Stop'
$repo = 'https://api.github.com/repos/ericg2/Vaulton-UI/releases/latest'
$headers = @{ 'User-Agent' = 'Vaulton-Installer'; 'Accept' = 'application/vnd.github+json' }

Write-Host 'Finding the latest Vaulton release...' -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri $repo -Headers $headers
$version = ([string]$release.tag_name).TrimStart('v')
$asset = $release.assets | Where-Object { $_.name -eq "vaulton-$version-windows-setup.exe" } | Select-Object -First 1
if (-not $asset) {
    $asset = $release.assets | Where-Object { $_.name -eq 'Vaulton-Windows-Setup.exe' } | Select-Object -First 1
}
if (-not $asset) { throw "The latest release does not contain a Windows installer. See https://github.com/ericg2/Vaulton-UI/releases" }

$temp = Join-Path ([System.IO.Path]::GetTempPath()) "vaulton-$version-setup.exe"
Write-Host "Downloading Vaulton $version..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $temp
Write-Host 'Starting the installer...' -ForegroundColor Cyan
$process = Start-Process -FilePath $temp -ArgumentList '/SILENT' -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "Vaulton installer failed with exit code $($process.ExitCode)." }
Remove-Item $temp -Force -ErrorAction SilentlyContinue
Write-Host "Vaulton $version is installed." -ForegroundColor Green
