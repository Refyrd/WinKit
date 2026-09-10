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
Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinKit - App Installer" Width="800" Height="580" 
        WindowStartupLocation="CenterScreen" Background="#202020" Foreground="#FFFFFF"
        FontFamily="Segoe UI" FontSize="14">
    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Padding" Value="15,10"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="15"/>
        </Style>
    </Window.Resources>
    <Grid Margin="25">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Text="WinKit - App Installer" FontSize="32" FontWeight="SemiBold" Foreground="#4CC2FF" Margin="0,0,0,20"/>
        
        <TabControl Name="TabCats" Grid.Row="1" Background="#282828" BorderThickness="0" Padding="15">
        </TabControl>
        
        <Border Grid.Row="2" Background="#2D2D2D" CornerRadius="8" Padding="15" Margin="0,20,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Orientation="Horizontal" Grid.Column="0">
                    <Button Name="BtnSelectAll" Content="Select All" Width="100" Height="35" Margin="0,0,10,0" Background="#3E3E42" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                    <Button Name="BtnClearAll" Content="Clear All" Width="100" Height="35" Background="#3E3E42" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                </StackPanel>
                
                <StackPanel Orientation="Horizontal" Grid.Column="2">
                    <Button Name="BtnSave" Content="Save Preset" Width="100" Height="35" Margin="0,0,10,0" Background="#3E3E42" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                    <Button Name="BtnLoad" Content="Load Preset" Width="100" Height="35" Margin="0,0,10,0" Background="#3E3E42" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                    <Button Name="BtnInstall" Content="Install" Width="120" Height="35" Background="#4CC2FF" Foreground="Black" FontWeight="Bold" BorderThickness="0" Cursor="Hand"/>
                </StackPanel>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader([xml]$xaml))
$win = [Windows.Markup.XamlReader]::Load($reader)

$tabCats = $win.FindName("TabCats")
$btnSelectAll = $win.FindName("BtnSelectAll")
$btnClearAll = $win.FindName("BtnClearAll")
$btnSave = $win.FindName("BtnSave")
$btnLoad = $win.FindName("BtnLoad")
$btnInstall = $win.FindName("BtnInstall")

$checkBoxes = @()

for ($c = 0; $c -lt $cats.Count; $c++) {
    $tabItem = New-Object System.Windows.Controls.TabItem
    $tabItem.Header = $cats[$c]
    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = "Auto"
    $wrap = New-Object System.Windows.Controls.WrapPanel
    $wrap.Margin = "5"
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        if ($apps[$i].Cat -eq $c) {
            $chk = New-Object System.Windows.Controls.CheckBox
            $chk.Content = $apps[$i].Name
            $chk.Width = 220
            $chk.Margin = "10"
            $chk.FontSize = 14
            $chk.Tag = $i
            $chk.Foreground = "White"
            $chk.IsChecked = $apps[$i].Sel
            $checkBoxes += $chk
            $wrap.Children.Add($chk) > $null
        }
    }
    
    $scroll.Content = $wrap
    $tabItem.Content = $scroll
    $tabCats.Items.Add($tabItem) > $null
}

$btnSelectAll.Add_Click({
    $curIdx = $tabCats.SelectedIndex
    foreach ($chk in $checkBoxes) {
        $appIdx = $chk.Tag
        if ($apps[$appIdx].Cat -eq $curIdx) { $chk.IsChecked = $true }
    }
})

$btnClearAll.Add_Click({
    foreach ($chk in $checkBoxes) { $chk.IsChecked = $false }
})

$btnSave.Add_Click({
    $selIds = @()
    foreach ($chk in $checkBoxes) {
        if ($chk.IsChecked) { $selIds += $apps[$chk.Tag].Id }
    }
    if ($selIds) { $selIds | Out-File "$env:USERPROFILE\Documents\winkit-preset.txt" -Encoding utf8 }
    [System.Windows.MessageBox]::Show("Preset saved to Documents\winkit-preset.txt", "WinKit", 0, 64)
})

$btnLoad.Add_Click({
    if (Test-Path "$env:USERPROFILE\Documents\winkit-preset.txt") {
        $savedIds = Get-Content "$env:USERPROFILE\Documents\winkit-preset.txt"
        foreach ($chk in $checkBoxes) {
            if ($savedIds -contains $apps[$chk.Tag].Id) { $chk.IsChecked = $true }
        }
    } else {
        [System.Windows.MessageBox]::Show("No preset found in Documents folder.", "WinKit", 0, 48)
    }
})

$btnInstall.Add_Click({
    foreach ($chk in $checkBoxes) {
        $apps[$chk.Tag].Sel = $chk.IsChecked -eq $true
    }
    $win.DialogResult = $true
    $win.Close()
})

$res = $win.ShowDialog()
if ($res -ne $true) { exit }

$sel = @($apps | Where-Object { $_.Sel })
if ($sel.Count -eq 0) { exit }

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