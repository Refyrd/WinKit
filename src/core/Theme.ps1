# --- WinKit Theme Engine (WinRT Accent & Fluent Adaptive Theming) ---

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

$global:darkPalette = @{
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

$global:lightPalette = @{
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

$global:brushConverter = [System.Windows.Media.BrushConverter]::new()

$regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$isLightReg = (Get-ItemProperty -Path $regKey -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme -eq 1
$global:isDark = -not $isLightReg

function Set-Theme($palette) {
    foreach ($key in $palette.Keys) {
        $global:win.Resources[$key] = $global:brushConverter.ConvertFromString($palette[$key])
    }
}

function Update-AppTheme($fromManualClick = $false) {
    $global:win.Dispatcher.Invoke({
        # 1. Update Dark/Light Mode (from registry if NOT manually toggled)
        if (-not $fromManualClick) {
            $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            $isLightReg = (Get-ItemProperty -Path $regKey -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme -eq 1
            
            if ($isLightReg) { Set-Theme $global:lightPalette; $global:isDark = $false }
            else { Set-Theme $global:darkPalette; $global:isDark = $true }
        }

        # 2. Update Accent Color (Adaptive for Dark/Light mode using WinRT UISettings)
        $hex = "#55C5FF"
        $hoverHex = "#75D2FF"
        $pressedHex = "#30B5FF"
        try {
            $uiType = [Type]::GetType("Windows.UI.ViewManagement.UISettings, Windows.UI.ViewManagement, ContentType=WindowsRuntime")
            $uiSettings = [Activator]::CreateInstance($uiType)
            
            if ($global:isDark) {
                $baseType = [Windows.UI.ViewManagement.UIColorType]::AccentLight2
                $hoverType = [Windows.UI.ViewManagement.UIColorType]::AccentLight3
                $pressedType = [Windows.UI.ViewManagement.UIColorType]::AccentLight1
            } else {
                $baseType = [Windows.UI.ViewManagement.UIColorType]::Accent
                $hoverType = [Windows.UI.ViewManagement.UIColorType]::AccentLight1
                $pressedType = [Windows.UI.ViewManagement.UIColorType]::AccentDark1
            }
            
            $accent = $uiSettings.GetColorValue($baseType)
            $hex = "#{0:X2}{1:X2}{2:X2}" -f $accent.R, $accent.G, $accent.B

            $hover = $uiSettings.GetColorValue($hoverType)
            $hoverHex = "#{0:X2}{1:X2}{2:X2}" -f $hover.R, $hover.G, $hover.B

            $pressed = $uiSettings.GetColorValue($pressedType)
            $pressedHex = "#{0:X2}{1:X2}{2:X2}" -f $pressed.R, $pressed.G, $pressed.B
        } catch {
            try {
                $c = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\DWM').ColorizationColor
                $hex = "#{0:X6}" -f ($c -band 0xFFFFFF)
                $hoverHex = $hex
                $pressedHex = $hex
            } catch { $null = $_ }
        }

        $global:win.Resources["PrimaryClr"] = $global:brushConverter.ConvertFromString($hex)
        $global:win.Resources["PrimaryHoverClr"] = $global:brushConverter.ConvertFromString($hoverHex)
        $global:win.Resources["PrimaryPressedClr"] = $global:brushConverter.ConvertFromString($pressedHex)
        $global:win.Resources["ChkHoverBorder"] = $global:brushConverter.ConvertFromString($hex)
        $textHex = if ($global:isDark) { "#000000" } else { "#FFFFFF" }
        $global:win.Resources["PrimaryBtnTextClr"] = $global:brushConverter.ConvertFromString($textHex)

        $helper = New-Object System.Windows.Interop.WindowInteropHelper($global:win)
        $val = if ($global:isDark) { 1 } else { 0 }
        [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4) | Out-Null
        [Dwm]::DwmSetWindowAttribute($helper.Handle, 19, [ref]$val, 4) | Out-Null
    })
}

function Register-ThemeListener {
    $global:ThemeChangedHandler = [Microsoft.Win32.UserPreferenceChangedEventHandler] {
        param($s, $e)
        $null = $s; $null = $e
        if ($global:win.Dispatcher.CheckAccess()) {
            Update-AppTheme
        } else {
            $global:win.Dispatcher.Invoke({ Update-AppTheme })
        }
    }
    [Microsoft.Win32.SystemEvents]::add_UserPreferenceChanged($global:ThemeChangedHandler)
}

function Unregister-ThemeListener {
    if ($global:ThemeChangedHandler) {
        [Microsoft.Win32.SystemEvents]::remove_UserPreferenceChanged($global:ThemeChangedHandler)
    }
}
