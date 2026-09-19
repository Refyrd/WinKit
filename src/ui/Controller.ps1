# --- WinKit UI Controller & Event Handlers ---

function DoEvents {
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
        [System.Windows.Threading.DispatcherPriority]::Background, 
        [System.Action]({ $frame.Continue = $false })
    ) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

function Initialize-UIController($winControls) {
    $win = $winControls.Win
    $tabCats = $winControls.TabCats
    $btnSelectAll = $winControls.BtnSelectAll
    $btnClearAll = $winControls.BtnClearAll
    $btnSave = $winControls.BtnSave
    $btnLoad = $winControls.BtnLoad
    $btnInstall = $winControls.BtnInstall
    $btnCancelInstall = $winControls.BtnCancelInstall
    $btnTheme = $winControls.BtnTheme
    $btnDebug = $winControls.BtnDebug
    $ProgressOverlay = $winControls.ProgressOverlay
    $TxtLog = $winControls.TxtLog
    $SummaryScroll = $winControls.SummaryScroll
    $SummaryPanel = $winControls.SummaryPanel

    $script:isConsoleVisible = $false
    $script:checkBoxes = @()
    $global:depCheckBoxes = @{}

    # Populate categories and apps
    for ($c = 0; $c -lt $global:cats.Count; $c++) {
        $tabItem = New-Object System.Windows.Controls.TabItem
        $tabItem.Header = $global:cats[$c]
        $scroll = New-Object System.Windows.Controls.ScrollViewer
        $scroll.VerticalScrollBarVisibility = "Auto"
        $scroll.FocusVisualStyle = $null
        $wrap = New-Object System.Windows.Controls.WrapPanel
        $wrap.Margin = "5"
        
        $catApps = $global:apps | Where-Object { $_.Cat -eq $c }
        foreach ($app in $catApps) {
            $panel = New-Object System.Windows.Controls.StackPanel
            $panel.Orientation = "Vertical"
            $panel.Width = 220
            $panel.Margin = "0,0,0,5"
            
            $chk = New-Object System.Windows.Controls.CheckBox
            $chk.Content = $app.Name
            $chk.IsChecked = $app.Sel
            $chk.Uid = $app.Name
            $panel.Children.Add($chk) | Out-Null
            $script:checkBoxes += $chk
            
            if ($app.Dep) {
                $chkDep = New-Object System.Windows.Controls.CheckBox
                $chkDep.Content = "+ $($app.Dep)"
                $chkDep.IsChecked = $true
                $chkDep.Visibility = "Collapsed"
                $chkDep.Margin = "25,2,0,0"
                $chkDep.ToolTip = "Uncheck to skip installing $($app.Dep)"
                
                $global:depCheckBoxes[$app.Name] = $chkDep
                
                $chk.Tag = $chkDep
                $chk.Add_Checked({ $this.Tag.Visibility = "Visible" })
                $chk.Add_Unchecked({ $this.Tag.Visibility = "Collapsed" })
                
                $panel.Children.Add($chkDep) | Out-Null
            }
            
            $wrap.Children.Add($panel) | Out-Null
        }
        
        $scroll.Content = $wrap
        $tabItem.Content = $scroll
        $tabCats.Items.Add($tabItem) | Out-Null
    }

    # Theme toggle handler
    $btnTheme.Add_Click({
        $global:isDark = -not $global:isDark
        if ($global:isDark) { Set-Theme $global:darkPalette } else { Set-Theme $global:lightPalette }
        Update-AppTheme -fromManualClick $true
    })

    # Debug console toggle handler
    $btnDebug.Add_Click({
        if ($script:isConsoleVisible) {
            [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null
            $script:isConsoleVisible = $false
        } else {
            [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null
            $script:isConsoleVisible = $true
        }
    })

    # Preset handlers
    $btnSelectAll.Add_Click({
        foreach ($chk in $script:checkBoxes) { $chk.IsChecked = $true }
    })

    $btnClearAll.Add_Click({
        foreach ($chk in $script:checkBoxes) { $chk.IsChecked = $false }
    })

    $btnSave.Add_Click({
        $sel = @()
        foreach ($chk in $script:checkBoxes) {
            if ($chk.IsChecked -eq $true) { $sel += $chk.Uid }
        }
        $sel -join "`n" | Out-File -FilePath "$env:USERPROFILE\Documents\winkit-preset.txt" -Encoding utf8
        [System.Windows.MessageBox]::Show("Preset saved to Documents\winkit-preset.txt!", "Success", 0, 64)
    })

    $btnLoad.Add_Click({
        $path = "$env:USERPROFILE\Documents\winkit-preset.txt"
        if (Test-Path $path) {
            $lines = Get-Content $path
            foreach ($chk in $script:checkBoxes) {
                $chk.IsChecked = $lines -contains $chk.Uid
            }
        }
    })

    # Install cancel handler
    $global:cancelInstall = $false
    $btnCancelInstall.Add_Click({
        if ($global:cancelInstall) {
            $ProgressOverlay.Visibility = "Collapsed"
        } else {
            $global:cancelInstall = $true
            $btnCancelInstall.Content = "Cancelling..."
            $btnCancelInstall.IsEnabled = $false
        }
    })

    # Install button handler
    $btnInstall.Add_Click({
        $toInstall = @()
        foreach ($chk in $script:checkBoxes) {
            if ($chk.IsChecked -eq $true) {
                $name = $chk.Uid
                foreach ($app in $global:apps) {
                    if ($app.Name -eq $name) {
                        $toInstall += $app
                        break
                    }
                }
            }
        }

        if ($toInstall.Count -eq 0) { return }
        Write-Host "Install button clicked. Selected apps: $($toInstall.Count)" -ForegroundColor Cyan

        $ProgressOverlay.Visibility = "Visible"
        $TxtLog.Visibility = "Visible"
        $SummaryScroll.Visibility = "Collapsed"
        $SummaryPanel.Children.Clear()
        
        if (-not $global:isDark) {
            $TxtLog.Background = $global:brushConverter.ConvertFromString("#F0F0F0")
            $TxtLog.Foreground = $global:brushConverter.ConvertFromString("#111111")
        } else {
            $TxtLog.Background = $global:brushConverter.ConvertFromString("#1E1E1E")
            $TxtLog.Foreground = $global:brushConverter.ConvertFromString("#CCCCCC")
        }
        
        $global:cancelInstall = $false
        $TxtLog.Text = ""
        $btnCancelInstall.Content = "Cancel"
        $btnCancelInstall.IsEnabled = $true

        Start-AppsInstallation $toInstall $winControls
    })

    # Window DWM & Backdrop initialization
    $win.Add_SourceInitialized({
        $helper = New-Object System.Windows.Interop.WindowInteropHelper($win)
        $hwnd = $helper.Handle
        
        $margins = New-Object Dwm+MARGINS
        $margins.cxLeftWidth = -1
        $margins.cxRightWidth = -1
        $margins.cyTopHeight = -1
        $margins.cyBottomHeight = -1
        [Dwm]::DwmExtendFrameIntoClientArea($hwnd, [ref]$margins) | Out-Null
        
        $val = if ($global:isDark) { 1 } else { 0 }
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

    # Window cleanup
    $win.Add_Closed({
        Unregister-ThemeListener
    })
}
