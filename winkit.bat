@echo off
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

# --- App definitions ---
$apps = @(
    # Cat 0: Browsers
    @{Name="Google Chrome";      Id="Google.Chrome";              Cat=0; Sel=$false},
    @{Name="Mozilla Firefox";    Id="Mozilla.Firefox";            Cat=0; Sel=$false},
    @{Name="Brave Browser";      Id="Brave.Brave";               Cat=0; Sel=$false},
    @{Name="Vivaldi";            Id="VivaldiTechnologies.Vivaldi";Cat=0; Sel=$false},

    # Cat 1: Development
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"; Cat=1; Sel=$false},
    @{Name="Git";                Id="Git.Git";                    Cat=1; Sel=$false},
    @{Name="Python 3";           Id="Python.Python.3.12";         Cat=1; Sel=$false},
    @{Name="Node.js LTS";        Id="OpenJS.NodeJS.LTS";          Cat=1; Sel=$false},
    @{Name="Notepad++";          Id="Notepad++.Notepad++";        Cat=1; Sel=$false},
    @{Name="Docker Desktop";     Id="Docker.DockerDesktop";       Cat=1; Sel=$false},

    # Cat 2: Gaming / Social
    @{Name="Steam";              Id="Valve.Steam";                Cat=2; Sel=$false},
    @{Name="Discord";            Id="Discord.Discord";            Cat=2; Sel=$false},
    @{Name="Telegram";           Id="Telegram.TelegramDesktop";   Cat=2; Sel=$false},

    # Cat 3: Media
    @{Name="VLC Media Player";   Id="VideoLAN.VLC";               Cat=3; Sel=$false},
    @{Name="Spotify";            Id="Spotify.Spotify";            Cat=3; Sel=$false},
    @{Name="OBS Studio";         Id="OBSProject.OBSStudio";       Cat=3; Sel=$false},
    @{Name="K-Lite Codec Pack";  Id="CodecGuide.K-LiteCodecPack.Standard"; Cat=3; Sel=$false},
    @{Name="Audacity";           Id="Audacity.Audacity";          Cat=3; Sel=$false},
    @{Name="GIMP";               Id="GIMP.GIMP";                  Cat=3; Sel=$false},

    # Cat 4: Utilities
    @{Name="7-Zip";              Id="7zip.7zip";                  Cat=4; Sel=$false},
    @{Name="WinRAR";             Id="RARLab.WinRAR";              Cat=4; Sel=$false},
    @{Name="qBittorrent";        Id="qBittorrent.qBittorrent";    Cat=4; Sel=$false},
    @{Name="MSI Afterburner";    Id="Guru3D.Afterburner";         Cat=4; Sel=$false},
    @{Name="PowerToys";          Id="Microsoft.PowerToys";        Cat=4; Sel=$false},
    @{Name="Everything Search";  Id="voidtools.Everything";       Cat=4; Sel=$false},
    @{Name="Rufus";              Id="Rufus.Rufus";                Cat=4; Sel=$false},
    @{Name="ShareX";             Id="ShareX.ShareX";              Cat=4; Sel=$false},
    @{Name="Revo Uninstaller";   Id="VSRevoGroup.RevoUninstallerFree"; Cat=4; Sel=$false},
    @{Name="WizTree";            Id="AntibodySoftware.WizTree";   Cat=4; Sel=$false},

    # Cat 5: System
    @{Name="DirectX Web Setup";  Id="Microsoft.DirectX";          Cat=5; Sel=$false},
    @{Name="Visual C++ Redist";  Id="Microsoft.VCRedist.2015+.x64"; Cat=5; Sel=$false},
    @{Name="CPU-Z";              Id="CPUID.CPU-Z";                Cat=5; Sel=$false},
    @{Name="GPU-Z";              Id="TechPowerUp.GPU-Z";          Cat=5; Sel=$false},
    @{Name="HWMonitor";          Id="CPUID.HWMonitor";            Cat=5; Sel=$false},
    @{Name="CrystalDiskInfo";    Id="CrystalDewWorld.CrystalDiskInfo"; Cat=5; Sel=$false},

    # Cat 6: Productivity
    @{Name="Obsidian";           Id="Obsidian.Obsidian";          Cat=6; Sel=$false},
    @{Name="Notion";             Id="Notion.Notion";              Cat=6; Sel=$false}
)

$cats = @("Browsers", "Development", "Gaming / Social", "Media", "Utilities", "System", "Productivity")
$page = 0
$cur = 0

function Get-Items($p) {
    return @(0..($apps.Count-1) | Where-Object { $apps[$_].Cat -eq $p })
}

function Draw {
    [Console]::Clear()
    $sc = ($apps | Where-Object { $_.Sel }).Count
    $items = Get-Items $page

    Write-Host "`n  ======================================================" -Fore Cyan
    Write-Host "  |              WinKit - App Installer                |" -Fore Cyan
    Write-Host "  ======================================================`n" -Fore Cyan

    # Page tabs
    Write-Host "   " -NoNewline
    for ($p = 0; $p -lt $cats.Count; $p++) {
        if ($p -eq $page) { Write-Host " [$($p+1)]" -Fore White -NoNewline }
        else { Write-Host "  $($p+1) " -Fore DarkGray -NoNewline }
    }
    Write-Host "`n`n   $($cats[$page])`n" -Fore Yellow

    # Items
    for ($j = 0; $j -lt $items.Count; $j++) {
        $idx = $items[$j]
        $a = $apps[$idx]
        $n = $j + 1
        $pad = " " * (2 - "$n".Length)
        $check = if ($a.Sel) {"[x]"} else {"[ ]"}
        $arrow = if ($j -eq $cur) {">"} else {" "}
        $color = if ($a.Sel) {"Green"} elseif ($j -eq $cur) {"White"} else {"Gray"}

        Write-Host "   $arrow $pad$n. $check $($a.Name)" -Fore $color
    }

    # Pad empty lines to keep layout stable
    $empty = 8 - $items.Count
    if ($empty -gt 0) {
        for ($e = 0; $e -lt $empty; $e++) { Write-Host "" }
    }

    Write-Host "`n  ------------------------------------------------------" -Fore Cyan
    Write-Host "   Selected: " -Fore White -NoNewline
    Write-Host "$sc" -Fore Green -NoNewline
    Write-Host " of $($apps.Count)" -Fore White
    Write-Host "  ------------------------------------------------------`n" -Fore Cyan
    
    Write-Host "   [<] [>]" -Fore Cyan -NoNewline
    Write-Host " pages  " -Fore DarkGray -NoNewline
    Write-Host "[Space]" -Fore Cyan -NoNewline
    Write-Host " toggle  " -Fore DarkGray -NoNewline
    Write-Host "[A]" -Fore Green -NoNewline
    Write-Host " all/none" -Fore DarkGray
    Write-Host "   [Enter]" -Fore Green -NoNewline
    Write-Host " install  " -Fore DarkGray -NoNewline
    Write-Host "[C]" -Fore Yellow -NoNewline
    Write-Host " clear  " -Fore DarkGray -NoNewline
    Write-Host "[S]" -Fore Magenta -NoNewline
    Write-Host "/" -Fore DarkGray -NoNewline
    Write-Host "[L]" -Fore Magenta -NoNewline
    Write-Host " preset  " -Fore DarkGray -NoNewline
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
    $ch = $key.KeyChar.ToString()
    if ([int]::TryParse($ch, [ref]$null)) {
        $num = [int]$ch
        if ($num -ge 1 -and $num -le $items.Count) {
            $idx = $items[$num - 1]
            $apps[$idx].Sel = -not $apps[$idx].Sel
        }
    } else {
        switch ($key.Key) {
            "LeftArrow"  { if ($page -gt 0) { $page--; $cur = 0 } }
            "RightArrow" { if ($page -lt ($cats.Count - 1)) { $page++; $cur = 0 } }
            "UpArrow"    { if ($cur -gt 0) { $cur-- } }
            "DownArrow"  { if ($cur -lt ($items.Count - 1)) { $cur++ } }
            "Spacebar"   { if ($items.Count -gt 0) { $apps[$items[$cur]].Sel = -not $apps[$items[$cur]].Sel } }
            "A"          { 
                $pageApps = $apps[$items]
                $allSelected = ($pageApps | Where-Object { -not $_.Sel }).Count -eq 0
                foreach ($idx in $items) { $apps[$idx].Sel = -not $allSelected } 
            }
            "C"          { foreach ($a in $apps) { $a.Sel = $false } }
            "S"          {
                $selIds = $apps | Where-Object { $_.Sel } | ForEach-Object { $_.Id }
                if ($selIds) { $selIds | Out-File "$env:USERPROFILE\Documents\winkit-preset.txt" -Encoding utf8 }
            }
            "L"          {
                if (Test-Path "$env:USERPROFILE\Documents\winkit-preset.txt") {
                    $savedIds = Get-Content "$env:USERPROFILE\Documents\winkit-preset.txt"
                    foreach ($a in $apps) { if ($savedIds -contains $a.Id) { $a.Sel = $true } }
                }
            }
            "Escape"     { exit }
            "Enter" {
                $sel = $apps | Where-Object { $_.Sel }
                if ($sel.Count -gt 0) { $doInstall = $true }
            }
        }
    }
}

# === CONFIRM ===
$sel = @($apps | Where-Object { $_.Sel })

[Console]::Clear()
Write-Host ""
Write-Host "`n  ======================================================" -Fore Cyan
Write-Host "  |            Confirm Installation                    |" -Fore Cyan
Write-Host "  ======================================================`n" -Fore Cyan
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
[Console]::Clear()
Write-Host "`n  ==========================================================" -Fore Cyan
Write-Host "  |              Installing apps...                        |" -Fore Cyan
Write-Host "  ==========================================================`n" -Fore Cyan

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
Write-Host "`n  ==========================================================" -Fore Cyan
Write-Host "  |              Installation Results                      |" -Fore Cyan
Write-Host "  ==========================================================`n" -Fore Cyan
foreach ($r in $results) {
    if ($r.S -eq "OK") { Write-Host "     [OK]   $($r.N)" -Fore Green }
    else { Write-Host "     [FAIL] $($r.N)" -Fore Red }
}
Write-Host "`n  ----------------------------------------------------------" -Fore Cyan
Write-Host "   OK: $ok  |  Failed: $fail  |  Total: $($sel.Count)" -Fore White
Write-Host "  ----------------------------------------------------------`n" -Fore Cyan
Write-Host "  Press any key to exit..."
[Console]::ReadKey($true) | Out-Null