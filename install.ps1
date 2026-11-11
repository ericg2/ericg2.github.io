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

$checksumAsset = $release.assets | Where-Object { $_.name -eq "$($asset.name).sha256" } | Select-Object -First 1
if (-not $checksumAsset) { throw "The release is missing the installer's SHA-256 checksum." }

$temp = Join-Path ([System.IO.Path]::GetTempPath()) "vaulton-$version-setup.exe"
$checksumPath = "$temp.sha256"
try {
    Write-Host "Downloading Vaulton $version..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $temp
    Invoke-WebRequest -Uri $checksumAsset.browser_download_url -OutFile $checksumPath
    $expectedHash = ((Get-Content $checksumPath -Raw).Trim() -split '\s+')[0].ToUpperInvariant()
    $actualHash = (Get-FileHash $temp -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($expectedHash -ne $actualHash) { throw 'The installer checksum does not match. The download may be corrupted or tampered with.' }

    Write-Host 'Checksum verified. Starting the installer...' -ForegroundColor Cyan
    $process = Start-Process -FilePath $temp -ArgumentList '/SILENT' -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Vaulton installer failed with exit code $($process.ExitCode)." }
    Write-Host "Vaulton $version is installed." -ForegroundColor Green
}
finally {
    Remove-Item $temp, $checksumPath -Force -ErrorAction SilentlyContinue
}
