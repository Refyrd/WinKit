@echo off
chcp 65001 >nul

:: ===============================================================
::  WinKit - quick app installer powered by WinGet
::  GitHub: https://github.com/Refyrd/WinKit
:: ===============================================================

:: UAC elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0"""" admin", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)
if "%1"=="admin" cd /d "%~dp0"

setlocal EnableDelayedExpansion

:: Extract embedded PowerShell and run it
set "_ps=%temp%\winkit_menu.ps1"
for /f "delims=:" %%a in ('findstr /n "#POWERSHELL_BEGIN" "%~f0"') do set "_ln=%%a"
more +!_ln! "%~f0" > "!_ps!"
powershell -NoProfile -ExecutionPolicy Bypass -File "!_ps!"
del "!_ps!" >nul 2>&1
endlocal
exit /b

#POWERSHELL_BEGIN
$Host.UI.RawUI.WindowTitle = "WinKit - App Installer"
try {
    $buf = $Host.UI.RawUI.BufferSize
    $buf.Width = 60; $buf.Height = 300
    $Host.UI.RawUI.BufferSize = $buf
    $win = $Host.UI.RawUI.WindowSize
    $win.Width = 60; $win.Height = 26
    $Host.UI.RawUI.WindowSize = $win
} catch {}

# --- App definitions ---
$apps = @(
    @{Name="Google Chrome";      Id="Google.Chrome";              Cat=0; Sel=$false},
    @{Name="Mozilla Firefox";    Id="Mozilla.Firefox";            Cat=0; Sel=$false},
    @{Name="Brave Browser";      Id="Brave.Brave";               Cat=0; Sel=$false},
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"; Cat=1; Sel=$false},
    @{Name="Git";                Id="Git.Git";                    Cat=1; Sel=$false},
    @{Name="Python 3";           Id="Python.Python.3.12";         Cat=1; Sel=$false},
    @{Name="Node.js LTS";        Id="OpenJS.NodeJS.LTS";          Cat=1; Sel=$false},
    @{Name="Notepad++";          Id="Notepad++.Notepad++";        Cat=1; Sel=$false},
    @{Name="Steam";              Id="Valve.Steam";                Cat=2; Sel=$false},
    @{Name="Discord";            Id="Discord.Discord";            Cat=2; Sel=$false},
    @{Name="Telegram";           Id="Telegram.TelegramDesktop";   Cat=2; Sel=$false},
    @{Name="VLC Media Player";   Id="VideoLAN.VLC";               Cat=3; Sel=$false},
    @{Name="Spotify";            Id="Spotify.Spotify";            Cat=3; Sel=$false},
    @{Name="OBS Studio";         Id="OBSProject.OBSStudio";       Cat=3; Sel=$false},
    @{Name="7-Zip";              Id="7zip.7zip";                  Cat=4; Sel=$false},
    @{Name="WinRAR";             Id="RARLab.WinRAR";              Cat=4; Sel=$false},
    @{Name="qBittorrent";        Id="qBittorrent.qBittorrent";    Cat=4; Sel=$false},
    @{Name="MSI Afterburner";    Id="Guru3D.Afterburner";         Cat=4; Sel=$false},
    @{Name="PowerToys";          Id="Microsoft.PowerToys";        Cat=4; Sel=$false},
    @{Name="Everything Search";  Id="voidtools.Everything";       Cat=4; Sel=$false}
)

$cats = @("Browsers", "Development", "Gaming / Social", "Media", "Utilities")
$page = 0
$cur = 0

function Get-Items($p) {
    $r = @()
    for ($i = 0; $i -lt $apps.Count; $i++) {
        if ($apps[$i].Cat -eq $p) { $r += $i }
    }
    return $r
}

function Draw {
    [Console]::Clear()
    $sc = ($apps | Where-Object { $_.Sel }).Count
    $items = Get-Items $page

    Write-Host ""
    Write-Host "  ======================================================" -Fore Cyan
    Write-Host "  |" -Fore Cyan -NoNewline
    Write-Host "           WinKit - App Installer                " -Fore White -NoNewline
    Write-Host "|" -Fore Cyan
    Write-Host "  ======================================================" -Fore Cyan
    Write-Host ""

    # Page tabs
    Write-Host "   " -NoNewline
    for ($p = 0; $p -lt $cats.Count; $p++) {
        if ($p -eq $page) {
            Write-Host " [$($p+1)]" -Fore White -NoNewline
        } else {
            Write-Host "  $($p+1) " -Fore DarkGray -NoNewline
        }
    }
    Write-Host ""
    Write-Host ""
    Write-Host "   $($cats[$page])" -Fore Yellow
    Write-Host ""

    # Items
    for ($j = 0; $j -lt $items.Count; $j++) {
        $idx = $items[$j]
        $a = $apps[$idx]
        $n = $idx + 1
        $pad = if ($n -lt 10) {"  "} else {" "}
        $check = if ($a.Sel) {"[x]"} else {"[ ]"}
        $arrow = if ($j -eq $cur) {">"} else {" "}

        if ($j -eq $cur) {
            $color = if ($a.Sel) {"Green"} else {"White"}
        } else {
            $color = if ($a.Sel) {"Green"} else {"Gray"}
        }
        Write-Host "   $arrow $pad$n. $check $($a.Name)" -Fore $color
    }

    # Pad empty lines to keep layout stable
    $empty = 7 - $items.Count
    for ($e = 0; $e -lt $empty; $e++) { Write-Host "" }

    Write-Host ""
    Write-Host "  ------------------------------------------------------" -Fore Cyan
    Write-Host "   Selected: " -Fore White -NoNewline
    Write-Host "$sc" -Fore Green -NoNewline
    Write-Host " of $($apps.Count)" -Fore White
    Write-Host "  ------------------------------------------------------" -Fore Cyan
    Write-Host ""
    Write-Host "   " -NoNewline
    Write-Host "[<] [>]" -Fore Cyan -NoNewline
    Write-Host " pages  " -Fore DarkGray -NoNewline
    Write-Host "[Space]" -Fore Cyan -NoNewline
    Write-Host " toggle  " -Fore DarkGray -NoNewline
    Write-Host "[A]" -Fore Green -NoNewline
    Write-Host " all" -Fore DarkGray
    Write-Host "   " -NoNewline
    Write-Host "[Enter]" -Fore Green -NoNewline
    Write-Host " install  " -Fore DarkGray -NoNewline
    Write-Host "[C]" -Fore Yellow -NoNewline
    Write-Host " clear   " -Fore DarkGray -NoNewline
    Write-Host "[Esc]" -Fore Red -NoNewline
    Write-Host " exit" -Fore DarkGray
}

# === MAIN LOOP ===
$doInstall = $false
while (-not $doInstall) {
    $items = Get-Items $page
    if ($cur -ge $items.Count) { $cur = [Math]::Max(0, $items.Count - 1) }
    Draw

    $key = [Console]::ReadKey($true)
    switch ($key.Key) {
        "LeftArrow"  { if ($page -gt 0) { $page--; $cur = 0 } }
        "RightArrow" { if ($page -lt ($cats.Count - 1)) { $page++; $cur = 0 } }
        "UpArrow"    { if ($cur -gt 0) { $cur-- } }
        "DownArrow"  { if ($cur -lt ($items.Count - 1)) { $cur++ } }
        "Spacebar"   { if ($items.Count -gt 0) { $apps[$items[$cur]].Sel = -not $apps[$items[$cur]].Sel } }
        "A"          { foreach ($a in $apps) { $a.Sel = $true } }
        "C"          { foreach ($a in $apps) { $a.Sel = $false } }
        "Escape"     { exit }
        "Enter" {
            $sel = $apps | Where-Object { $_.Sel }
            if ($sel.Count -gt 0) { $doInstall = $true }
        }
    }
}

# === CONFIRM ===
$sel = @($apps | Where-Object { $_.Sel })

[Console]::Clear()
Write-Host ""
Write-Host "  ======================================================" -Fore Cyan
Write-Host "  |" -Fore Cyan -NoNewline
Write-Host "            Confirm Installation                 " -Fore White -NoNewline
Write-Host "|" -Fore Cyan
Write-Host "  ======================================================" -Fore Cyan
Write-Host ""
Write-Host "   Will install $($sel.Count) app(s):" -Fore Green
Write-Host ""
foreach ($a in $sel) {
    Write-Host "     - $($a.Name)" -Fore White -NoNewline
    Write-Host "  [$($a.Id)]" -Fore DarkGray
}
Write-Host ""
Write-Host "  ------------------------------------------------------" -Fore Cyan
Write-Host ""
Write-Host "   [Enter] Start  |  [Esc] Back" -Fore DarkGray

while ($true) {
    $k = [Console]::ReadKey($true)
    if ($k.Key -eq "Escape") { exit }
    if ($k.Key -eq "Enter") { break }
}

# === INSTALL ===
try {
    $buf = $Host.UI.RawUI.BufferSize
    $buf.Width = 80; $buf.Height = 1000
    $Host.UI.RawUI.BufferSize = $buf
    $win = $Host.UI.RawUI.WindowSize
    $win.Width = 80; $win.Height = 30
    $Host.UI.RawUI.WindowSize = $win
} catch {}

[Console]::Clear()
Write-Host ""
Write-Host "  ==========================================================" -Fore Cyan
Write-Host "  |" -Fore Cyan -NoNewline
Write-Host "              Installing apps...                       " -Fore White -NoNewline
Write-Host "|" -Fore Cyan
Write-Host "  ==========================================================" -Fore Cyan
Write-Host ""

$ok = 0; $fail = 0; $done = 0
$results = @()

foreach ($a in $sel) {
    $done++
    Write-Host "  ----------------------------------------------------------" -Fore Cyan
    Write-Host "   [$done/$($sel.Count)] " -Fore White -NoNewline
    Write-Host "$($a.Name)" -Fore Yellow
    Write-Host "   Package: $($a.Id)" -Fore DarkGray
    Write-Host "  ----------------------------------------------------------" -Fore Cyan
    Write-Host ""

    winget install --id $a.Id -e --source winget --accept-package-agreements --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        $ok++
        Write-Host ""
        Write-Host "   [OK] $($a.Name)" -Fore Green
        $results += @{S="OK"; N=$a.Name}
    } else {
        $fail++
        Write-Host ""
        Write-Host "   [FAIL] $($a.Name)" -Fore Red
        $results += @{S="FAIL"; N=$a.Name}
    }
    Write-Host ""
}

# === RESULTS ===
Write-Host ""
Write-Host "  ==========================================================" -Fore Cyan
Write-Host "  |" -Fore Cyan -NoNewline
Write-Host "              Installation Results                     " -Fore White -NoNewline
Write-Host "|" -Fore Cyan
Write-Host "  ==========================================================" -Fore Cyan
Write-Host ""
foreach ($r in $results) {
    if ($r.S -eq "OK") {
        Write-Host "     [OK]   $($r.N)" -Fore Green
    } else {
        Write-Host "     [FAIL] $($r.N)" -Fore Red
    }
}
Write-Host ""
Write-Host "  ----------------------------------------------------------" -Fore Cyan
Write-Host "   OK: $ok  |  Failed: $fail  |  Total: $($sel.Count)" -Fore White
Write-Host "  ----------------------------------------------------------" -Fore Cyan
Write-Host ""
Write-Host "  Press any key to exit..."
[Console]::ReadKey($true) | Out-Null