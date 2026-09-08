# WinKit — Quick Install Script
# Run with: irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex

Write-Host ""
Write-Host "  ⚡ WinKit — Downloading installer..." -ForegroundColor Cyan
Write-Host ""

$tempDir = Join-Path $env:TEMP "WinKit"
if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

$batUrl = "https://raw.githubusercontent.com/Refyrd/WinKit/main/winkit.bat"
$batPath = Join-Path $tempDir "winkit.bat"

try {
    Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing
    Write-Host "  Done! Launching WinKit..." -ForegroundColor Green
    Write-Host "  This window will close when WinKit exits." -ForegroundColor DarkGray
    Write-Host ""
    Start-Process cmd -ArgumentList "/c `"$batPath`"" -Verb RunAs -Wait
    Write-Host "  WinKit finished." -ForegroundColor Green
} catch {
    Write-Host "  Download failed: $_" -ForegroundColor Red
    Write-Host "  Try: git clone https://github.com/Refyrd/WinKit.git" -ForegroundColor Gray
}

