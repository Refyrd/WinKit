# WinKit — Quick Install Script
# Run with: irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex

Write-Host ""
Write-Host "  ⚡ WinKit — Downloading installer..." -ForegroundColor Cyan
Write-Host ""

$tempDir = Join-Path $env:TEMP "WinKit"
if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

$batUrl = "https://raw.githubusercontent.com/Refyrd/WinKit/main/winkit.ps1"
$batPath = Join-Path $tempDir "winkit.ps1"

try {
    Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing
    Write-Host "  Done! Launching WinKit..." -ForegroundColor Green
    Write-Host "  This window will close when WinKit exits." -ForegroundColor DarkGray
    Write-Host ""
    $argList = "-Sta -ExecutionPolicy Bypass -NoProfile -File `"$batPath`""
    Start-Process powershell.exe -ArgumentList $argList -Wait
    Write-Host "  WinKit finished." -ForegroundColor Green
} catch {
    Write-Host "  Download failed: $_" -ForegroundColor Red
    Write-Host "  Try: git clone https://github.com/Refyrd/WinKit.git" -ForegroundColor Gray
}

