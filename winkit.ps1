param([switch]$Elevated)

# Auto-elevate and enforce STA if run directly
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSTA = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if (-not $isAdmin -or -not $isSTA) {
    if ($PSCommandPath) {
        $argList = "-Sta -ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`" -Elevated"
        try {
            Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -Wait
        } catch { }
        exit
    }
}

$Host.UI.RawUI.WindowTitle = "WinKit - Backend Service"
Write-Host "WinKit GUI Initialization..." -ForegroundColor Cyan

# Hide Console Window while GUI is active
Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")]public static extern IntPtr GetConsoleWindow();[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);' -ErrorAction Ignore
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null

# --- App definitions ---
$apps = @(
    @{Name="Google Chrome";      Id="Google.Chrome";              Cat=0; Sel=$false},
    @{Name="Mozilla Firefox";    Id="Mozilla.Firefox";            Cat=0; Sel=$false},
    @{Name="Brave Browser";      Id="Brave.Brave";               Cat=0; Sel=$false},
    @{Name="Vivaldi";            Id="VivaldiTechnologies.Vivaldi";Cat=0; Sel=$false},
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"; Cat=1; Sel=$false},
    @{Name="Git";                Id="Git.Git";                    Cat=1; Sel=$false},
    @{Name="Python 3";           Id="Python.Python.3.12";         Cat=1; Sel=$false},
    @{Name="Node.js LTS";        Id="OpenJS.NodeJS.LTS";          Cat=1; Sel=$false},
    @{Name="Notepad++";          Id="Notepad++.Notepad++";        Cat=1; Sel=$false},
    @{Name="Docker Desktop";     Id="Docker.DockerDesktop";       Cat=1; Sel=$false},
    @{Name="Steam";              Id="Valve.Steam";                Cat=2; Sel=$false},
    @{Name="Discord";            Id="Discord.Discord";            Cat=2; Sel=$false},
    @{Name="Telegram";           Id="Telegram.TelegramDesktop";   Cat=2; Sel=$false},
    @{Name="VLC Media Player";   Id="VideoLAN.VLC";               Cat=3; Sel=$false},
    @{Name="Spotify";            Id="Spotify.Spotify";            Cat=3; Sel=$false},
    @{Name="OBS Studio";         Id="OBSProject.OBSStudio";       Cat=3; Sel=$false},
    @{Name="K-Lite Codec Pack";  Id="CodecGuide.K-LiteCodecPack.Standard"; Cat=3; Sel=$false},
    @{Name="Audacity";           Id="Audacity.Audacity";          Cat=3; Sel=$false},
    @{Name="GIMP";               Id="GIMP.GIMP";                  Cat=3; Sel=$false},
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
    @{Name="DirectX Web Setup";  Id="Microsoft.DirectX";          Cat=5; Sel=$false},
    @{Name="Visual C++ Redist";  Id="Microsoft.VCRedist.2015+.x64"; Cat=5; Sel=$false},
    @{Name="CPU-Z";              Id="CPUID.CPU-Z";                Cat=5; Sel=$false},
    @{Name="GPU-Z";              Id="TechPowerUp.GPU-Z";          Cat=5; Sel=$false},
    @{Name="HWMonitor";          Id="CPUID.HWMonitor";            Cat=5; Sel=$false},
    @{Name="CrystalDiskInfo";    Id="CrystalDewWorld.CrystalDiskInfo"; Cat=5; Sel=$false},
    @{Name="Obsidian";           Id="Obsidian.Obsidian";          Cat=6; Sel=$false},
    @{Name="Notion";             Id="Notion.Notion";              Cat=6; Sel=$false}
)

$cats = @("Browsers", "Development", "Gaming / Social", "Media", "Utilities", "System", "Productivity")
Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinKit - App Installer" Width="800" Height="580" 
        WindowStartupLocation="CenterScreen" Background="Transparent" Foreground="#FFFFFF"
        WindowStyle="None" AllowsTransparency="False" ResizeMode="CanMinimize"
        FontFamily="Segoe UI Variable Text, Segoe UI" FontSize="14">
    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Margin" Value="0,0,6,0"/>
            <Setter Property="Padding" Value="12,8,12,10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Grid>
                            <Border Name="Border" Background="{TemplateBinding Background}" CornerRadius="6"/>
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="{TemplateBinding Padding}"/>
                            <Border x:Name="Indicator" Height="3" CornerRadius="1.5" Background="#55C5FF" VerticalAlignment="Bottom" Margin="8,0,8,2" Visibility="Collapsed"/>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#1AFFFFFF"/>
                                <Setter TargetName="Indicator" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#0DFFFFFF"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsSelected" Value="True"/>
                                    <Condition Property="IsMouseOver" Value="True"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="Border" Property="Background" Value="#1AFFFFFF"/>
                            </MultiTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#3D3D3D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#353535"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#282828"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button" x:Key="PrimaryButton" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="#55C5FF"/>
            <Setter Property="Foreground" Value="Black"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#75D2FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#30B5FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Margin" Value="10"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal">
                            <Border x:Name="checkBoxBorder" Width="20" Height="20" 
                                    BorderBrush="#3D3D3D" BorderThickness="1.5" 
                                    Background="#2D2D2D" CornerRadius="4" 
                                    VerticalAlignment="Center">
                                <Path x:Name="checkMark" Fill="Black" Visibility="Collapsed" 
                                      Data="M 4,10 L 8,14 L 16,5 L 14,3 L 8,10 L 6,8 Z" Stretch="Fill" Margin="3"/>
                            </Border>
                            <ContentPresenter Margin="10,0,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="checkMark" Property="Visibility" Value="Visible"/>
                                <Setter TargetName="checkBoxBorder" Property="Background" Value="#55C5FF"/>
                                <Setter TargetName="checkBoxBorder" Property="BorderBrush" Value="#55C5FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="checkBoxBorder" Property="BorderBrush" Value="#75D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Border BorderThickness="0" Background="Transparent" CornerRadius="0">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            
            <Grid Grid.Row="0" Name="TitleBar" Background="Transparent" Height="32">
                <TextBlock Text="WinKit - App Installer" VerticalAlignment="Center" Margin="15,0,0,0" FontSize="12" Foreground="#AAAAAA" />
                <Button Name="BtnClose" Content="✕" Width="46" HorizontalAlignment="Right" Background="Transparent" BorderThickness="0" Foreground="White" FontSize="12" Cursor="Arrow"/>
            </Grid>
            
            <Grid Grid.Row="1" Background="#801E1E1E" Margin="0">
                <Grid Margin="25,5,25,25">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <TextBlock Text="App Installer" FontSize="32" FontWeight="SemiBold" Foreground="#FFFFFF" Margin="0,0,0,20"/>
                    
                    <TabControl Name="TabCats" Grid.Row="1" Background="Transparent" BorderThickness="0" Padding="15">
                    </TabControl>
                    
                    <Border Grid.Row="2" Background="#602D2D2D" BorderBrush="#353535" BorderThickness="1" CornerRadius="8" Padding="15" Margin="0,20,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            
                            <StackPanel Orientation="Horizontal" Grid.Column="0">
                                <Button Name="BtnSelectAll" Content="Select All" Width="100" Height="35" Margin="0,0,10,0"/>
                                <Button Name="BtnClearAll" Content="Clear All" Width="100" Height="35"/>
                            </StackPanel>
                            
                            <StackPanel Orientation="Horizontal" Grid.Column="2">
                                <Button Name="BtnSave" Content="Save Preset" Width="100" Height="35" Margin="0,0,10,0"/>
                                <Button Name="BtnLoad" Content="Load Preset" Width="100" Height="35" Margin="0,0,10,0"/>
                                <Button Name="BtnInstall" Content="Install" Width="120" Height="35" Style="{StaticResource PrimaryButton}" FontWeight="Bold"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
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
$btnClose = $win.FindName("BtnClose")
$titleBar = $win.FindName("TitleBar")

$titleBar.Add_MouseLeftButtonDown({
    param($sender, $e)
    $win.DragMove()
})

$btnClose.Add_Click({
    $win.DialogResult = $false
    $win.Close()
})

$checkBoxes = @()
for ($c = 0; $c -lt $cats.Count; $c++) {
    $tabItem = New-Object System.Windows.Controls.TabItem
    $tabItem.Header = $cats[$c]
    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = "Auto"
    $wrap = New-Object System.Windows.Controls.WrapPanel
    $wrap.Margin = "5"
    
    $catApps = $apps | Where-Object { $_.Cat -eq $c }
    foreach ($app in $catApps) {
        $chk = New-Object System.Windows.Controls.CheckBox
        $chk.Content = $app.Name
        $chk.IsChecked = $app.Sel
        $chk.Tag = $app.Name
        $chk.Width = 220
        $wrap.Children.Add($chk) | Out-Null
        $checkBoxes += $chk
    }
    
    $scroll.Content = $wrap
    $tabItem.Content = $scroll
    $tabCats.Items.Add($tabItem) | Out-Null
}

$btnSelectAll.Add_Click({ foreach ($chk in $checkBoxes) { $chk.IsChecked = $true } })
$btnClearAll.Add_Click({ foreach ($chk in $checkBoxes) { $chk.IsChecked = $false } })

$btnSave.Add_Click({
    $sel = @()
    foreach ($chk in $checkBoxes) {
        if ($chk.IsChecked -eq $true) { $sel += $chk.Tag }
    }
    $sel -join "`n" | Out-File -FilePath "$env:USERPROFILE\Documents\winkit-preset.txt" -Encoding utf8
    [System.Windows.MessageBox]::Show("Preset saved to Documents\winkit-preset.txt!", "Success", 0, 64)
})
$btnLoad.Add_Click({
    $path = "$env:USERPROFILE\Documents\winkit-preset.txt"
    if (Test-Path $path) {
        $lines = Get-Content $path
        foreach ($chk in $checkBoxes) {
            $chk.IsChecked = $lines -contains $chk.Tag
        }
    }
})

$btnInstall.Add_Click({
    foreach ($chk in $checkBoxes) {
        $name = $chk.Tag
        for ($i=0; $i -lt $apps.Count; $i++) {
            if ($apps[$i].Name -eq $name) { $apps[$i].Sel = ($chk.IsChecked -eq $true) }
        }
    }
    $win.DialogResult = $true
    $win.Close()
})

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Dwm {
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS {
        public int cxLeftWidth;
        public int cxRightWidth;
        public int cyTopHeight;
        public int cyBottomHeight;
    }
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    [DllImport("dwmapi.dll")]
    public static extern int DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS margins);
}
"@ -ErrorAction Ignore

$win.Add_SourceInitialized({
    $helper = New-Object System.Windows.Interop.WindowInteropHelper($win)
    $hwnd = $helper.Handle
    
    $margins = New-Object Dwm+MARGINS
    $margins.cxLeftWidth = -1
    $margins.cxRightWidth = -1
    $margins.cyTopHeight = -1
    $margins.cyBottomHeight = -1
    [Dwm]::DwmExtendFrameIntoClientArea($hwnd, [ref]$margins) | Out-Null
    
    $trueVal = 1
    [Dwm]::DwmSetWindowAttribute($hwnd, 20, [ref]$trueVal, 4) | Out-Null
    
    $backdrop = 2
    [Dwm]::DwmSetWindowAttribute($hwnd, 38, [ref]$backdrop, 4) | Out-Null
    
    $micaFallback = 1
    [Dwm]::DwmSetWindowAttribute($hwnd, 1029, [ref]$micaFallback, 4) | Out-Null

    $hwndSource = [System.Windows.Interop.HwndSource]::FromHwnd($hwnd)
    if ($hwndSource -ne $null) {
        $hwndSource.CompositionTarget.BackgroundColor = [System.Windows.Media.Colors]::Transparent
    }
})

$res = $win.ShowDialog()

# Restore console window
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null

if ($res -ne $true) { exit }

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " WinKit - Installing Selected Apps" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$toInstall = @()
foreach ($app in $apps) { if ($app.Sel) { $toInstall += $app } }

if ($toInstall.Count -eq 0) { exit }

$count = 1
$total = $toInstall.Count
foreach ($app in $toInstall) {
    Write-Host "[$count/$total] Installing $($app.Name)..." -ForegroundColor Yellow
    winget install --id=$($app.Id) --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) { Write-Host "  Success: $($app.Name)" -ForegroundColor Green }
    else { Write-Host "  Failed/Skipped: $($app.Name)" -ForegroundColor Red }
    $count++
}

Start-Sleep -Seconds 3
