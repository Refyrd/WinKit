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
    $script:winControls = $winControls
    $script:win = $winControls.Win
    $script:tabCats = $winControls.TabCats
    $script:btnSelectAll = $winControls.BtnSelectAll
    $script:btnClearAll = $winControls.BtnClearAll
    $script:btnSave = $winControls.BtnSave
    $script:btnLoad = $winControls.BtnLoad
    $script:btnInstall = $winControls.BtnInstall
    $script:btnCancelInstall = $winControls.BtnCancelInstall
    $script:btnTheme = $winControls.BtnTheme
    $script:btnDebug = $winControls.BtnDebug
    $script:ProgressOverlay = $winControls.ProgressOverlay
    $script:TxtLog = $winControls.TxtLog
    $script:SummaryScroll = $winControls.SummaryScroll
    $script:SummaryPanel = $winControls.SummaryPanel
    $script:txtSearch = $winControls.TxtSearch
    $script:txtSearchPlaceholder = $winControls.TxtSearchPlaceholder
    $script:btnClearSearch = $winControls.BtnClearSearch
    $script:btnExportLog = $winControls.BtnExportLog

    $script:isConsoleVisible = $false
    $script:checkBoxes = @()
    $script:appPanels = @()
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
            $panel.Tag = @{ App = $app; CatIndex = $c }
            
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
            $script:appPanels += $panel
        }
        
        $scroll.Content = $wrap
        $tabItem.Content = $scroll
        $script:tabCats.Items.Add($tabItem) | Out-Null
    }

    # Search filter handlers
    if ($script:txtSearch) {
        $script:txtSearch.Add_TextChanged({
            $q = $script:txtSearch.Text.Trim()
            if ($q) {
                if ($script:txtSearchPlaceholder) { $script:txtSearchPlaceholder.Visibility = "Collapsed" }
                if ($script:btnClearSearch) { $script:btnClearSearch.Visibility = "Visible" }
            } else {
                if ($script:txtSearchPlaceholder) { $script:txtSearchPlaceholder.Visibility = "Visible" }
                if ($script:btnClearSearch) { $script:btnClearSearch.Visibility = "Collapsed" }
            }

            $firstMatchingTab = -1
            $currentTabHasMatch = $false
            $currTabIdx = $script:tabCats.SelectedIndex

            foreach ($p in $script:appPanels) {
                $app = $p.Tag.App
                $catIdx = $p.Tag.CatIndex
                if (-not $q -or ($app.Name -like "*$q*")) {
                    $p.Visibility = "Visible"
                    if ($catIdx -eq $currTabIdx) { $currentTabHasMatch = $true }
                    if ($firstMatchingTab -eq -1) { $firstMatchingTab = $catIdx }
                } else {
                    $p.Visibility = "Collapsed"
                }
            }

            if ($q -and -not $currentTabHasMatch -and $firstMatchingTab -ge 0) {
                $script:tabCats.SelectedIndex = $firstMatchingTab
            }
        })
    }

    if ($script:btnClearSearch) {
        $script:btnClearSearch.Add_Click({
            $script:txtSearch.Text = ""
        })
    }

    # Theme toggle handler
    $script:btnTheme.Add_Click({
        $global:isDark = -not $global:isDark
        if ($global:isDark) { Set-Theme $global:darkPalette } else { Set-Theme $global:lightPalette }
        Update-AppTheme -fromManualClick $true
    })

    # Debug console toggle handler
    $script:btnDebug.Add_Click({
        if ($script:isConsoleVisible) {
            [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null
            $script:isConsoleVisible = $false
        } else {
            [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 5) | Out-Null
            $script:isConsoleVisible = $true
        }
    })

    # Preset handlers
    $script:btnSelectAll.Add_Click({
        foreach ($chk in $script:checkBoxes) { $chk.IsChecked = $true }
    })

    $script:btnClearAll.Add_Click({
        foreach ($chk in $script:checkBoxes) { $chk.IsChecked = $false }
    })

    # Preset save handler with path selection
    $script:btnSave.Add_Click({
        $sel = @()
        foreach ($chk in $script:checkBoxes) {
            if ($chk.IsChecked -eq $true) { $sel += $chk.Uid }
        }
        if ($sel.Count -eq 0) {
            [System.Windows.MessageBox]::Show("No applications are selected to save.", "WinKit Preset", 0, 48)
            return
        }

        $sfd = New-Object Microsoft.Win32.SaveFileDialog
        $sfd.Title = "Save WinKit Preset"
        $sfd.Filter = "WinKit Preset (*.txt)|*.txt|All Files (*.*)|*.*"
        $sfd.FileName = "winkit-preset.txt"
        $docs = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        if ($docs -and (Test-Path $docs)) { $sfd.InitialDirectory = $docs }

        if ($sfd.ShowDialog() -eq $true) {
            try {
                $sel -join "`n" | Out-File -FilePath $sfd.FileName -Encoding utf8
                [System.Windows.MessageBox]::Show("Preset saved successfully to:`n$($sfd.FileName)", "Success", 0, 64)
            } catch {
                [System.Windows.MessageBox]::Show("Failed to save preset: $_", "Error", 0, 16)
            }
        }
    })

    # Preset load handler with path selection
    $script:btnLoad.Add_Click({
        $ofd = New-Object Microsoft.Win32.OpenFileDialog
        $ofd.Title = "Load WinKit Preset"
        $ofd.Filter = "WinKit Preset (*.txt)|*.txt|All Files (*.*)|*.*"
        $ofd.FileName = "winkit-preset.txt"
        $docs = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        if ($docs -and (Test-Path $docs)) { $ofd.InitialDirectory = $docs }

        if ($ofd.ShowDialog() -eq $true) {
            if (Test-Path $ofd.FileName) {
                try {
                    $lines = @(Get-Content $ofd.FileName | ForEach-Object { $_.Trim() } | Where-Object { $_ })
                    $matchedCount = 0
                    foreach ($chk in $script:checkBoxes) {
                        $isChecked = $lines -contains $chk.Uid
                        $chk.IsChecked = $isChecked
                        if ($isChecked) { $matchedCount++ }
                    }
                    [System.Windows.MessageBox]::Show("Loaded preset with $matchedCount selected application(s).", "WinKit", 0, 64)
                } catch {
                    [System.Windows.MessageBox]::Show("Failed to load preset: $_", "Error", 0, 16)
                }
            }
        }
    })

    # Export Log handler
    if ($script:btnExportLog) {
        $script:btnExportLog.Add_Click({
            $logContent = $script:TxtLog.Text
            if (-not $logContent) {
                [System.Windows.MessageBox]::Show("No installation log available to export.", "WinKit Export", 0, 48)
                return
            }

            $sfd = New-Object Microsoft.Win32.SaveFileDialog
            $sfd.Title = "Export Installation Log"
            $sfd.Filter = "Log File (*.log)|*.log|Text File (*.txt)|*.txt|All Files (*.*)|*.*"
            $sfd.FileName = "winkit-install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
            $docs = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
            if ($docs -and (Test-Path $docs)) { $sfd.InitialDirectory = $docs }

            if ($sfd.ShowDialog() -eq $true) {
                try {
                    [System.IO.File]::WriteAllText($sfd.FileName, $logContent, [System.Text.UTF8Encoding]::new($false))
                    [System.Windows.MessageBox]::Show("Log exported successfully to:`n$($sfd.FileName)", "WinKit", 0, 64)
                } catch {
                    [System.Windows.MessageBox]::Show("Failed to save log: $_", "Error", 0, 16)
                }
            }
        })
    }

    # Install cancel / close handler
    $global:cancelInstall = $false
    $global:isInstallFinished = $false
    $script:btnCancelInstall.Add_Click({
        if ($this.Content -eq "Close" -or $global:isInstallFinished) {
            $script:ProgressOverlay.Visibility = "Collapsed"
            $script:btnInstall.IsEnabled = $true
        } else {
            $global:cancelInstall = $true
            $this.Content = "Cancelling..."
            $this.IsEnabled = $false
        }
    })

    # Install button handler
    $script:btnInstall.Add_Click({
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
        $script:btnInstall.IsEnabled = $false
        Write-Host "Install button clicked. Selected apps: $($toInstall.Count)" -ForegroundColor Cyan

        $script:ProgressOverlay.Visibility = "Visible"
        $script:TxtLog.Visibility = "Visible"
        $script:SummaryScroll.Visibility = "Collapsed"
        $script:SummaryPanel.Children.Clear()
        
        if (-not $global:isDark) {
            $script:TxtLog.Background = $global:brushConverter.ConvertFromString("#F0F0F0")
            $script:TxtLog.Foreground = $global:brushConverter.ConvertFromString("#111111")
        } else {
            $script:TxtLog.Background = $global:brushConverter.ConvertFromString("#1E1E1E")
            $script:TxtLog.Foreground = $global:brushConverter.ConvertFromString("#CCCCCC")
        }
        
        $global:cancelInstall = $false
        $script:TxtLog.Text = ""
        $script:btnCancelInstall.Content = "Cancel"
        $script:btnCancelInstall.IsEnabled = $true
        if ($script:btnExportLog) { $script:btnExportLog.Visibility = "Collapsed" }
        DoEvents

        try {
            Start-AppsInstallation $toInstall $script:winControls
        } finally {
            $script:btnInstall.IsEnabled = $true
        }
    })

    # Window DWM & Backdrop initialization
    $script:win.Add_SourceInitialized({
        $helper = New-Object System.Windows.Interop.WindowInteropHelper($script:win)
        $hwnd = $helper.Handle
        
        $margins = New-Object Dwm+MARGINS
        $margins.cxLeftWidth = -1
        $margins.cxRightWidth = -1
        $margins.cyTopHeight = -1
        $margins.cyBottomHeight = -1
        [Dwm]::DwmExtendFrameIntoClientArea($hwnd, [ref]$margins) | Out-Null
        
        $val = if ($global:isDark) { 1 } else { 0 }
        [Dwm]::DwmSetWindowAttribute($hwnd, 20, [ref]$val, 4) | Out-Null
        
        if ($global:isWin11) {
            $backdrop = 2
            [Dwm]::DwmSetWindowAttribute($hwnd, 38, [ref]$backdrop, 4) | Out-Null

            $micaFallback = 1
            [Dwm]::DwmSetWindowAttribute($hwnd, 1029, [ref]$micaFallback, 4) | Out-Null

            $hwndSource = [System.Windows.Interop.HwndSource]::FromHwnd($hwnd)
            if ($null -ne $hwndSource) {
                $hwndSource.CompositionTarget.BackgroundColor = [System.Windows.Media.Colors]::Transparent
            }
        }
    })

    # Window cleanup
    $script:win.Add_Closed({
        Unregister-ThemeListener
    })
}
