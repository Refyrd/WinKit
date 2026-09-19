# WinKit — Quick Install Script
# Run with: irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex

Write-Host ""
Write-Host "  ⚡ WinKit — Downloading application..." -ForegroundColor Cyan
Write-Host ""

$tempDir = Join-Path $env:TEMP "WinKit"
if (Test-Path $tempDir) { Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$zipUrl = "https://github.com/Refyrd/WinKit/archive/refs/heads/main.zip"
$zipPath = Join-Path $tempDir "winkit.zip"

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    $entryScript = Join-Path $tempDir "WinKit-main\winkit.ps1"
    
    if (Test-Path $entryScript) {
        Write-Host "  Done! Launching WinKit..." -ForegroundColor Green
        Write-Host "  This window will close when WinKit exits." -ForegroundColor DarkGray
        Write-Host ""
        $argList = "-Sta -ExecutionPolicy Bypass -NoProfile -File `"$entryScript`""
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -Wait
        Write-Host "  WinKit finished." -ForegroundColor Green
    } else {
        throw "Could not locate winkit.ps1 in extracted archive."
    }
} catch {
    Write-Host "  Launch failed: $_" -ForegroundColor Red
    Write-Host "  Try: git clone https://github.com/Refyrd/WinKit.git" -ForegroundColor Gray
} finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
