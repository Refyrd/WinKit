param([switch]$Elevated)
$null = $Elevated

# Auto-elevate and enforce STA if run directly
$global:isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSTA = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

$scriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }

if (-not $global:isAdmin -or -not $isSTA) {
    if ($scriptPath) {
        $argList = "-Sta -ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`""
        try {
            Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -Wait
        } catch { $null = $_ }
        exit
    }
}

$Host.UI.RawUI.WindowTitle = "WinKit - Backend Service"
Write-Host "WinKit GUI Initialization..." -ForegroundColor Cyan

# Ensure WinGet is present (auto-download via Microsoft.WinGet.Client on stripped OS builds)
function Ensure-WinGet {
    $hasWinget = [bool](Get-Command "winget.exe" -ErrorAction SilentlyContinue)
    $winApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    if (-not $hasWinget -and (Test-Path "$winApps\winget.exe")) {
        $env:PATH += ";$winApps"
        $hasWinget = [bool](Get-Command "winget.exe" -ErrorAction SilentlyContinue)
    }

    if (-not $hasWinget) {
        Write-Host "[!] WinGet was not detected on this system." -ForegroundColor Yellow
        Write-Host "[*] Bootstrapping WinGet via Microsoft.WinGet.Client..." -ForegroundColor Cyan
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null
            }
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
            Install-Module -Name Microsoft.WinGet.Client -Force -Confirm:$false -Scope AllUsers -ErrorAction Stop
            Import-Module Microsoft.WinGet.Client -Force -ErrorAction Stop
            if (Get-Command Repair-WinGetPackageManager -ErrorAction SilentlyContinue) {
                Repair-WinGetPackageManager -Latest -Force -ErrorAction Stop
            }
            $env:PATH = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
            if (Test-Path "$winApps\winget.exe") { $env:PATH += ";$winApps" }
            Write-Host "[+] WinGet successfully installed!" -ForegroundColor Green
        } catch {
            Write-Warning "Could not automatically install WinGet: $_"
            Write-Host "Please ensure internet access and PowerShell Gallery availability." -ForegroundColor Yellow
        }
    }
}

Ensure-WinGet

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
    Win                  = $global:win
    TabCats              = $global:win.FindName("TabCats")
    BtnSelectAll         = $global:win.FindName("BtnSelectAll")
    BtnClearAll          = $global:win.FindName("BtnClearAll")
    BtnSave              = $global:win.FindName("BtnSave")
    BtnLoad              = $global:win.FindName("BtnLoad")
    BtnInstall           = $global:win.FindName("BtnInstall")
    BtnTheme             = $global:win.FindName("BtnTheme")
    BtnDebug             = $global:win.FindName("BtnDebug")
    ProgressOverlay      = $global:win.FindName("ProgressOverlay")
    LblProgressTitle     = $global:win.FindName("LblProgressTitle")
    LblProgress          = $global:win.FindName("LblProgress")
    PbInstall            = $global:win.FindName("PbInstall")
    TxtLog               = $global:win.FindName("TxtLog")
    SummaryScroll        = $global:win.FindName("SummaryScroll")
    SummaryPanel         = $global:win.FindName("SummaryPanel")
    BtnCancelInstall     = $global:win.FindName("BtnCancelInstall")
    TxtSearch            = $global:win.FindName("TxtSearch")
    TxtSearchPlaceholder = $global:win.FindName("TxtSearchPlaceholder")
    BtnClearSearch       = $global:win.FindName("BtnClearSearch")
    BtnExportLog         = $global:win.FindName("BtnExportLog")
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
