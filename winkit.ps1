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
        WindowStartupLocation="CenterScreen" Background="Transparent" Foreground="{DynamicResource AppText}"
        WindowStyle="SingleBorderWindow" AllowsTransparency="False"
        FontFamily="Segoe UI Variable Text, Segoe UI" FontSize="14">
    <Window.Resources>
        <SolidColorBrush x:Key="AppBg"          Color="#B31E1E1E"/>
        <SolidColorBrush x:Key="AppText"        Color="#FFFFFF"/>
        <SolidColorBrush x:Key="ControlBg"      Color="#2D2D2D"/>
        <SolidColorBrush x:Key="BorderClr"      Color="#3D3D3D"/>
        <SolidColorBrush x:Key="HoverBg"        Color="#353535"/>
        <SolidColorBrush x:Key="PressedBg"      Color="#282828"/>
        <SolidColorBrush x:Key="BottomBarBg"    Color="#602D2D2D"/>
        <SolidColorBrush x:Key="TabSelBg"       Color="#1AFFFFFF"/>
        <SolidColorBrush x:Key="TabHoverBg"     Color="#0DFFFFFF"/>
        <SolidColorBrush x:Key="ChkBg"          Color="#2D2D2D"/>
        <SolidColorBrush x:Key="ChkBorder"      Color="#3D3D3D"/>
        <SolidColorBrush x:Key="ChkHoverBorder" Color="#75D2FF"/>

        <Style TargetType="TabControl">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="15"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="ItemsPanel">
                <Setter.Value>
                    <ItemsPanelTemplate>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,8"/>
                    </ItemsPanelTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TabItem">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource AppText}"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Margin" Value="0"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Background="Transparent" Padding="0,0,8,0">
                            <Border x:Name="TabBorder" CornerRadius="6" Background="Transparent" Padding="14,7,14,8">
                                <Grid>
                                    <ContentPresenter ContentSource="Header" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    <Border x:Name="SelectionIndicator" Height="2.5" CornerRadius="1.5" Background="#55C5FF" 
                                            VerticalAlignment="Bottom" Margin="4,0,4,-6" Visibility="Collapsed"/>
                                </Grid>
                            </Border>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="TabBorder" Property="Background" Value="{DynamicResource TabSelBg}"/>
                                <Setter TargetName="SelectionIndicator" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsMouseOver" Value="True"/>
                                    <Condition Property="IsSelected" Value="False"/>
                                </MultiTrigger.Conditions>
                                <Setter TargetName="TabBorder" Property="Background" Value="{DynamicResource TabHoverBg}"/>
                            </MultiTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource ControlBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource AppText}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderClr}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="{DynamicResource HoverBg}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="{DynamicResource PressedBg}"/>
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
                        <Border Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
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
            <Setter Property="Foreground" Value="{DynamicResource AppText}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Margin" Value="10"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border x:Name="MainBorder" Width="20" Height="20" Background="{DynamicResource ChkBg}" BorderBrush="{DynamicResource ChkBorder}" BorderThickness="1" CornerRadius="4">
                                <Path x:Name="CheckMark" Width="11" Height="8" Stretch="Uniform" Data="M 0,4 L 4,8 L 11,0" Stroke="#000000" StrokeThickness="1.8" StrokeEndLineCap="Round" StrokeStartLineCap="Round" StrokeLineJoin="Round" HorizontalAlignment="Center" VerticalAlignment="Center" Visibility="Collapsed"/>
                            </Border>
                            <ContentPresenter Margin="8,0,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="MainBorder" Property="Background" Value="#4CC2FF"/>
                                <Setter TargetName="MainBorder" Property="BorderBrush" Value="#4CC2FF"/>
                                <Setter TargetName="CheckMark" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="MainBorder" Property="BorderBrush" Value="{DynamicResource ChkHoverBorder}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Grid Background="Transparent">
        <Grid Margin="25">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            <Grid Grid.Row="0" Margin="0,0,0,20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="App Installer" FontSize="32" FontWeight="SemiBold" Foreground="{DynamicResource AppText}" VerticalAlignment="Center"/>
                <Button x:Name="BtnTheme" Grid.Column="1" Width="36" Height="36" Padding="0" Background="Transparent" BorderThickness="0" FocusVisualStyle="{x:Null}" Cursor="Hand" VerticalAlignment="Center">
                    <Path Data="M 12,22 C 17.52,22 22,17.52 22,12 C 22,6.48 17.52,2 12,2 C 6.48,2 2,6.48 2,12 C 2,17.52 6.48,22 12,22 Z M 12,20 C 7.58,20 4,16.42 4,12 C 4,7.58 7.58,4 12,4 L 12,20 Z" 
                          Fill="{DynamicResource AppText}" Stretch="Uniform" Margin="6"/>
                </Button>
            </Grid>
            
            <TabControl Name="TabCats" Grid.Row="1" Background="Transparent" BorderThickness="0" Padding="15" FocusVisualStyle="{x:Null}">
            </TabControl>
            
            <Border Grid.Row="2" Background="{DynamicResource BottomBarBg}" BorderBrush="{DynamicResource BorderClr}" BorderThickness="1" CornerRadius="8" Padding="15" Margin="0,20,0,0">
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
$btnTheme = $win.FindName("BtnTheme")

# ===== THEME PALETTES =====
$regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$isLightReg = (Get-ItemProperty -Path $regKey -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme -eq 1
$script:isDark = -not $isLightReg

$darkPalette = @{
    AppBg          = "#B31E1E1E"
    AppText        = "#FFFFFF"
    ControlBg      = "#2D2D2D"
    BorderClr      = "#3D3D3D"
    HoverBg        = "#353535"
    PressedBg      = "#282828"
    BottomBarBg    = "#602D2D2D"
    TabSelBg       = "#1AFFFFFF"
    TabHoverBg     = "#0DFFFFFF"
    ChkBg          = "#2D2D2D"
    ChkBorder      = "#3D3D3D"
    ChkHoverBorder = "#75D2FF"
}

$lightPalette = @{
    AppBg          = "#C0F3F3F3"
    AppText        = "#1B1B1B"
    ControlBg      = "#FFFFFF"
    BorderClr      = "#D1D1D1"
    HoverBg        = "#E5E5E5"
    PressedBg      = "#D0D0D0"
    BottomBarBg    = "#90FFFFFF"
    TabSelBg       = "#15000000"
    TabHoverBg     = "#08000000"
    ChkBg          = "#FFFFFF"
    ChkBorder      = "#C8C8C8"
    ChkHoverBorder = "#0067C0"
}

$brushConverter = [System.Windows.Media.BrushConverter]::new()
function Set-Theme($palette) {
    foreach ($key in $palette.Keys) {
        $win.Resources[$key] = $brushConverter.ConvertFromString($palette[$key])
    }
}

if (-not $script:isDark) { Set-Theme $lightPalette }

$btnTheme.Add_Click({
    $script:isDark = -not $script:isDark
    if ($script:isDark) { Set-Theme $darkPalette } else { Set-Theme $lightPalette }
    
    $helper = New-Object System.Windows.Interop.WindowInteropHelper($win)
    $val = if ($script:isDark) { 1 } else { 0 }
    [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4) | Out-Null
})

$checkBoxes = @()
for ($c = 0; $c -lt $cats.Count; $c++) {
    $tabItem = New-Object System.Windows.Controls.TabItem
    $tabItem.Header = $cats[$c]
    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = "Auto"
    $scroll.FocusVisualStyle = $null
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
    
    $val = if ($script:isDark) { 1 } else { 0 }
    [Dwm]::DwmSetWindowAttribute($hwnd, 20, [ref]$val, 4) | Out-Null
    
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
