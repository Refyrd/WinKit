param([switch]$Elevated)

# Auto-elevate and enforce STA if run directly
$global:isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSTA = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if (-not $global:isAdmin -or -not $isSTA) {
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

# Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing, System.Windows.Forms

# Resolve Script Directory and Load Modules
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

. "$scriptDir\src\config\Apps.ps1"
. "$scriptDir\src\core\Theme.ps1"
. "$scriptDir\src\core\Installer.ps1"
. "$scriptDir\src\ui\Controller.ps1"

# Load XAML Layout
$xamlPath = Join-Path $scriptDir "src\ui\Layout.xaml"
$xaml = Get-Content -Path $xamlPath -Raw -Encoding UTF8
$reader = New-Object System.Xml.XmlNodeReader([xml]$xaml)
$global:win = [Windows.Markup.XamlReader]::Load($reader)

# Map UI Controls
$winControls = @{
    Win               = $global:win
    TabCats           = $global:win.FindName("TabCats")
    BtnSelectAll      = $global:win.FindName("BtnSelectAll")
    BtnClearAll       = $global:win.FindName("BtnClearAll")
    BtnSave           = $global:win.FindName("BtnSave")
    BtnLoad           = $global:win.FindName("BtnLoad")
    BtnInstall        = $global:win.FindName("BtnInstall")
    BtnTheme          = $global:win.FindName("BtnTheme")
    BtnDebug          = $global:win.FindName("BtnDebug")
    ProgressOverlay   = $global:win.FindName("ProgressOverlay")
    LblProgressTitle  = $global:win.FindName("LblProgressTitle")
    LblProgress       = $global:win.FindName("LblProgress")
    PbInstall         = $global:win.FindName("PbInstall")
    TxtLog            = $global:win.FindName("TxtLog")
    SummaryScroll     = $global:win.FindName("SummaryScroll")
    SummaryPanel      = $global:win.FindName("SummaryPanel")
    BtnCancelInstall  = $global:win.FindName("BtnCancelInstall")
}

# Initialize UI Controller & Theme
Initialize-UIController $winControls
Update-AppTheme
Register-ThemeListener

# Display Window
$global:win.ShowDialog() | Out-Null

# Restore Console Window upon exit
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null
exit
