param([switch]$Elevated)

# Auto-elevate and enforce STA if run directly
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSTA = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if (-not $isAdmin -or -not $isSTA) {
    if ($PSCommandPath) {
        $argList = "-Sta -ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`""
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
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="App Installer" FontSize="32" FontWeight="SemiBold" Foreground="{DynamicResource AppText}" VerticalAlignment="Center"/>
                
                <Button x:Name="BtnDebug" Grid.Column="1" Width="36" Height="36" Padding="0" Background="Transparent" BorderThickness="0" FocusVisualStyle="{x:Null}" Cursor="Hand" VerticalAlignment="Center" Margin="0,0,5,0" ToolTip="Toggle Console">
                    <Path Data="M3,4 H21 V20 H3 V4 Z M5,6 V18 H19 V6 Z M7,8 L10,11 L7,14 L8,15 L12,11 L8,7 Z M12,14 H17 V15 H12 Z" 
                          Fill="{DynamicResource AppText}" Stretch="Uniform" Margin="6"/>
                </Button>
                
                <Button x:Name="BtnTheme" Grid.Column="2" Width="36" Height="36" Padding="0" Background="Transparent" BorderThickness="0" FocusVisualStyle="{x:Null}" Cursor="Hand" VerticalAlignment="Center" ToolTip="Toggle Theme">
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
        
        <Grid Name="ProgressOverlay" Visibility="Collapsed" Background="{DynamicResource AppBg}">
            <Border Background="{DynamicResource ControlBg}" BorderBrush="{DynamicResource BorderClr}" BorderThickness="1" CornerRadius="8" Margin="40" Padding="20">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Name="LblProgressTitle" Text="Installing Apps..." FontSize="24" FontWeight="SemiBold" Foreground="{DynamicResource AppText}" Margin="0,0,0,15"/>
                    <TextBlock Name="LblProgress" Text="Preparing..." FontSize="16" Foreground="{DynamicResource AppText}" Margin="0,0,0,10" Grid.Row="1"/>
                    <ProgressBar Name="PbInstall" Height="4" IsIndeterminate="True" Grid.Row="1" VerticalAlignment="Bottom" Margin="0,0,0,0" BorderThickness="0" Background="{DynamicResource ControlHover}" Foreground="#55C5FF"/>

                    <Grid Grid.Row="2" Margin="0,15,0,15">
                        <TextBox Name="TxtLog" Background="#1E1E1E" Foreground="#CCCCCC" FontFamily="Consolas" FontSize="13" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" BorderThickness="0" Padding="10"/>
                        <ScrollViewer Name="SummaryScroll" Visibility="Collapsed" VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="SummaryPanel" Orientation="Vertical"/>
                        </ScrollViewer>
                    </Grid>

                    <Button Name="BtnCancelInstall" Grid.Row="3" Content="Cancel" Width="150" Height="35" HorizontalAlignment="Right"/>
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
$btnDebug = $win.FindName("BtnDebug")
$ProgressOverlay = $win.FindName("ProgressOverlay")
$LblProgressTitle = $win.FindName("LblProgressTitle")
$LblProgress = $win.FindName("LblProgress")
$PbInstall = $win.FindName("PbInstall")
$TxtLog = $win.FindName("TxtLog")
$SummaryScroll = $win.FindName("SummaryScroll")
$SummaryPanel = $win.FindName("SummaryPanel")
$BtnCancelInstall = $win.FindName("BtnCancelInstall")

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

$script:isConsoleVisible = $false
$btnDebug.Add_Click({
    if ($script:isConsoleVisible) {
        [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null
        $script:isConsoleVisible = $false
    } else {
        [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null
        $script:isConsoleVisible = $true
    }
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

function DoEvents {
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke([System.Windows.Threading.DispatcherPriority]::Background, [System.Action]( { $frame.Continue = $false } )) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

$global:cancelInstall = $false

$btnInstall.Add_Click({
    $toInstall = @()
    foreach ($chk in $checkBoxes) {
        if ($chk.IsChecked -eq $true) {
            $name = $chk.Tag
            foreach ($app in $apps) {
                if ($app.Name -eq $name) {
                    $toInstall += $app
                    break
                }
            }
        }
    }

    if ($toInstall.Count -eq 0) { return }
    Write-Host "Install button clicked. Selected apps: $($toInstall.Count)" -ForegroundColor Yellow

    $ProgressOverlay.Visibility = "Visible"
    $TxtLog.Visibility = "Visible"
    $SummaryScroll.Visibility = "Collapsed"
    $SummaryPanel.Children.Clear()
    
    if (-not $script:isDark) {
        $TxtLog.Background = $brushConverter.ConvertFromString("#F0F0F0")
        $TxtLog.Foreground = $brushConverter.ConvertFromString("#111111")
    } else {
        $TxtLog.Background = $brushConverter.ConvertFromString("#1E1E1E")
        $TxtLog.Foreground = $brushConverter.ConvertFromString("#CCCCCC")
    }
    
    $global:cancelInstall = $false
    $TxtLog.Text = ""
    $BtnCancelInstall.Content = "Cancel"
    $BtnCancelInstall.IsEnabled = $true
    $LblProgressTitle.Text = "Installing Apps..."
    $PbInstall.IsIndeterminate = $true
    $PbInstall.Visibility = "Visible"

    $installResults = @()

    $count = 0
    foreach ($app in $toInstall) {
        $appLog = ""
        if ($global:cancelInstall) {
            $TxtLog.AppendText("`n[!] Installation Cancelled by User.`n")
            $TxtLog.ScrollToEnd()
            $installResults += @{ App = $app; Code = -1; Cancelled = $true; Log = "" }
            continue
        }
        $count++
        $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name)"
        $TxtLog.AppendText("`n---> Starting: $($app.Name)`n")
        $TxtLog.ScrollToEnd()
        DoEvents

        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo.FileName = "winget"
        $proc.StartInfo.Arguments = "install --id=$($app.Id) --silent --disable-interactivity --accept-package-agreements --accept-source-agreements"
        $proc.StartInfo.RedirectStandardOutput = $true
        $proc.StartInfo.RedirectStandardError = $true
        $proc.StartInfo.UseShellExecute = $false
        $proc.StartInfo.CreateNoWindow = $true
        $proc.StartInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
        $proc.StartInfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8

        $proc.Start() | Out-Null
        Write-Host "Started winget process for $($app.Name)..." -ForegroundColor Cyan
        
        $lineBuffer = ""

        while (-not $proc.HasExited) {
            if ($global:cancelInstall) {
                try { $proc.Kill() } catch {}
                break
            }
            while ($proc.StandardOutput.Peek() -gt -1) {
                $char = [char]$proc.StandardOutput.Read()
                $TxtLog.AppendText($char)
                $appLog += $char
                try { [Console]::Write($char) } catch {}
                
                if ($char -eq "`n" -or $char -eq "`r") {
                    if ($lineBuffer -match "(\d+(?:\.\d+)?\s*[KMG]B\s*/\s*\d+(?:\.\d+)?\s*[KMG]B)") {
                        $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name) - $($matches[1])"
                    } elseif ($lineBuffer -match "(\d+\s*%)") {
                        $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name) - $($matches[1])"
                    }
                    $lineBuffer = ""
                } else {
                    $lineBuffer += $char
                }
                
                $TxtLog.ScrollToEnd()
            }
            DoEvents
            Start-Sleep -Milliseconds 20
        }

        if (-not $global:cancelInstall) {
            $out = $proc.StandardOutput.ReadToEnd()
            $err = $proc.StandardError.ReadToEnd()
            if ($out) { $TxtLog.AppendText($out); $appLog += $out; try { [Console]::Write($out) } catch {} }
            if ($err) { $TxtLog.AppendText($err); $appLog += $err; try { [Console]::Write($err) } catch {} }
            
            $finalCode = $proc.ExitCode
            
            if ($appLog -match "cannot be run from an administrator context") {
                $TxtLog.AppendText("`n[!] Administrator block detected. Retrying as normal user in background...`n")
                $TxtLog.ScrollToEnd()
                Write-Host "Admin block detected for $($app.Name). Retrying via explorer.exe..." -ForegroundColor Yellow

                $tmpOut = "$env:TEMP\winget_out_$($app.Id).log"
                $tmpDone = "$env:TEMP\winget_done_$($app.Id).log"
                if (Test-Path $tmpOut) { Remove-Item $tmpOut -Force }
                if (Test-Path $tmpDone) { Remove-Item $tmpDone -Force }
                
                $batPath = "$env:TEMP\winget_run_$($app.Id).bat"
                $vbsPath = "$env:TEMP\winget_run_$($app.Id).vbs"
                
                $batCmd = "@echo off`nwinget install --id=$($app.Id) --silent --accept-package-agreements --accept-source-agreements > `"$tmpOut`" 2>&1`necho %ERRORLEVEL% > `"$tmpDone`""
                Set-Content -Path $batPath -Value $batCmd -Encoding ASCII
                
                $vbsCmd = "Set WshShell = CreateObject(`"WScript.Shell`")`nWshShell.Run chr(34) & `"$batPath`" & Chr(34), 0`nSet WshShell = Nothing"
                Set-Content -Path $vbsPath -Value $vbsCmd -Encoding ASCII
                
                Start-Process "explorer.exe" -ArgumentList "`"$vbsPath`""
                
                $lastSize = 0
                while (-not (Test-Path $tmpDone)) {
                    if ($global:cancelInstall) { break }
                    if (Test-Path $tmpOut) {
                        try {
                            $fs = New-Object System.IO.FileStream($tmpOut, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                            $sr = New-Object System.IO.StreamReader($fs)
                            $sr.BaseStream.Seek($lastSize, [System.IO.SeekOrigin]::Begin) | Out-Null
                            $newText = $sr.ReadToEnd()
                            $lastSize = $sr.BaseStream.Position
                            $sr.Close()
                            
                            if ($newText) {
                                $TxtLog.AppendText($newText)
                                $appLog += $newText
                                $TxtLog.ScrollToEnd()
                                try { [Console]::Write($newText) } catch {}
                            }
                        } catch {}
                    }
                    DoEvents
                    Start-Sleep -Milliseconds 100
                }
                
                if (Test-Path $tmpDone) {
                    $finalCode = (Get-Content $tmpDone).Trim() -as [int]
                }
            }

            $TxtLog.AppendText("`n---> Done: $($app.Name) (Exit Code: $finalCode)`n")
            $TxtLog.ScrollToEnd()
            $installResults += @{ App = $app; Code = $finalCode; Cancelled = $false; Log = $appLog }
            Write-Host "Finished $($app.Name) with code $finalCode" -ForegroundColor Green
            DoEvents
        } else {
            $installResults += @{ App = $app; Code = -1; Cancelled = $true; Log = $appLog }
        }
    }

    $TxtLog.Visibility = "Collapsed"
    $PbInstall.Visibility = "Collapsed"
    $SummaryScroll.Visibility = "Visible"

    if ($global:cancelInstall) {
        $LblProgressTitle.Text = "Installation Aborted"
    } else {
        $LblProgressTitle.Text = "Installation Complete"
    }
    
    $PbInstall.IsIndeterminate = $false
    $PbInstall.Value = 100
    $LblProgress.Text = "Finished!"
    
    $global:allLogControls = @()

    foreach ($res in $installResults) {
        $color = "#28A745"
        $code = $res.Code
        $logStr = $res.Log
        
        $isUpToDate = ($code -eq -1978335220 -or $code -eq 2316632076 -or $code -eq -1978335189 -or $code -eq 2316632107 -or ($logStr -match "No newer package versions" -or $logStr -match "No available upgrade found"))
        
        if ($res.Cancelled) { $color = "#FFC107" }
        elseif ($code -ne 0 -and -not $isUpToDate) { $color = "#DC3545" }
        
        $desc = "Successfully installed"
        if ($res.Cancelled) { $desc = "Skipped - you hit the brakes!" }
        elseif ($isUpToDate) { $desc = "Already up to date (Nothing to do here)" }
        elseif ($code -eq 1618) { $desc = "Busy! Another installation is running (Code 1618)" }
        elseif ($code -eq 1602 -or $code -eq -2147023673 -or $code -eq 2147943623) { $desc = "Halted! Check logs (Cancelled or UAC denied)" }
        elseif ($code -eq 1603) { $desc = "Fatal crash! Check the logs for clues (Code 1603)" }
        elseif ($code -ne 0) {
            $desc = "Oops, something broke! Check logs (Code: $code)"
        }

        $bdr = New-Object System.Windows.Controls.Border
        $bdr.BorderThickness = "4,0,0,0"
        $bdr.BorderBrush = $brushConverter.ConvertFromString($color)
        $bdr.Margin = "0,0,0,8"
        $bdr.Padding = "10"
        $bdr.CornerRadius = "4"
        if (-not $script:isDark) { $bdr.Background = $brushConverter.ConvertFromString("#0A000000") }
        else { $bdr.Background = $brushConverter.ConvertFromString("#15FFFFFF") }

        $sp = New-Object System.Windows.Controls.StackPanel
        $t1 = New-Object System.Windows.Controls.TextBlock
        $t1.Text = $res.App.Name
        $t1.FontWeight = [System.Windows.FontWeights]::Bold
        $t1.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "AppText")
        $t1.FontSize = 14

        $t2 = New-Object System.Windows.Controls.TextBlock
        $t2.Text = $desc
        $t2.Foreground = $brushConverter.ConvertFromString($color)
        $t2.FontSize = 12
        $t2.Margin = "0,4,0,0"
        $t2.TextWrapping = "Wrap"

        $sp.Children.Add($t1) | Out-Null
        $sp.Children.Add($t2) | Out-Null
        
        if ($logStr -and $logStr.Trim().Length -gt 0) {
            $logBdr = New-Object System.Windows.Controls.Border
            $logBdr.CornerRadius = "6"
            $logBdr.Margin = "0,10,0,0"
            $logBdr.Visibility = "Collapsed"
            if (-not $script:isDark) { $logBdr.Background = $brushConverter.ConvertFromString("#F0F0F0") }
            else { $logBdr.Background = $brushConverter.ConvertFromString("#181818") }

            $tLog = New-Object System.Windows.Controls.TextBox
            $tLog.Text = $logStr.Trim()
            $tLog.Background = [System.Windows.Media.Brushes]::Transparent
            if (-not $script:isDark) { $tLog.Foreground = $brushConverter.ConvertFromString("#111111") }
            else { $tLog.Foreground = $brushConverter.ConvertFromString("#EEEEEE") }
            $tLog.TextWrapping = "Wrap"
            $tLog.FontFamily = "Consolas"
            $tLog.FontSize = 12
            $tLog.Height = 150
            $tLog.VerticalScrollBarVisibility = "Auto"
            $tLog.IsReadOnly = $true
            $tLog.BorderThickness = 0
            $tLog.Padding = "8"
            
            $logBdr.Child = $tLog

            $btnLog = New-Object System.Windows.Controls.Button
            $btnLog.Content = "Show Log"
            $btnLog.Padding = "10,2,10,2"
            $btnLog.Margin = "0,6,0,0"
            $btnLog.HorizontalAlignment = "Left"
            $btnLog.Background = $brushConverter.ConvertFromString("Transparent")
            $btnLog.Foreground = $brushConverter.ConvertFromString("#55C5FF")
            $btnLog.BorderThickness = 0
            $btnLog.Cursor = [System.Windows.Input.Cursors]::Hand
            
            $btnLog.Tag = @($logBdr, $tLog)
            $global:allLogControls += $btnLog
            
            $btnLog.Add_Click({
                $targetBdr = $this.Tag[0]
                $targetTxt = $this.Tag[1]
                $isOpening = ($targetBdr.Visibility -eq "Collapsed")
                
                foreach ($btn in $global:allLogControls) {
                    $btn.Tag[0].Visibility = "Collapsed"
                    $btn.Content = "Show Log"
                }
                
                if ($isOpening) {
                    $targetBdr.Visibility = "Visible"
                    $this.Content = "Hide Log"
                    $targetTxt.ScrollToEnd()
                }
            })

            $sp.Children.Add($btnLog) | Out-Null
            $sp.Children.Add($logBdr) | Out-Null
        }

        $bdr.Child = $sp
        $SummaryPanel.Children.Add($bdr) | Out-Null
    }

    $BtnCancelInstall.Content = "Close"
    $BtnCancelInstall.IsEnabled = $true
    $global:cancelInstall = $true
})

$BtnCancelInstall.Add_Click({
    if ($global:cancelInstall) {
        $ProgressOverlay.Visibility = "Collapsed"
    } else {
        $global:cancelInstall = $true
        $BtnCancelInstall.Content = "Cancelling..."
        $BtnCancelInstall.IsEnabled = $false
    }
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

$win.ShowDialog() | Out-Null

# Restore console window before exit
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null
exit
