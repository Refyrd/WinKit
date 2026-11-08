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
    $script:onlineCheckBoxes = @()
    $script:appPanels = @()
    $script:registeredApps = @{}
    $global:depCheckBoxes = @{}

    function Update-InstallCount {
        $count = 0
        foreach ($chk in ($script:checkBoxes + $script:onlineCheckBoxes)) {
            if ($chk.IsChecked -eq $true) { $count++ }
        }
        if ($count -gt 0) {
            $script:btnInstall.Content = "Install ($count)"
        } else {
            $script:btnInstall.Content = "Install"
        }
    }

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
            $script:registeredApps[$app.Name] = $app
            $panel = New-Object System.Windows.Controls.StackPanel
            $panel.Orientation = "Vertical"
            $panel.Width = 220
            $panel.Margin = "0,0,0,5"
            $panel.Tag = @{ App = $app; CatIndex = $c }
            
            $chk = New-Object System.Windows.Controls.CheckBox
            $chk.Content = $app.Name
            $chk.IsChecked = $app.Sel
            $chk.Uid = $app.Name
            $chk.Add_Checked({ Update-InstallCount })
            $chk.Add_Unchecked({ Update-InstallCount })
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

    # 🌐 WinGet Online Search Tab
    $onlineTab = New-Object System.Windows.Controls.TabItem
    $onlineTab.Header = "🌐 WinGet Search"
    $script:onlineSearchTab = $onlineTab

    $onlineGrid = New-Object System.Windows.Controls.Grid
    $onlineGrid.Margin = "10,5,10,5"
    $r1 = New-Object System.Windows.Controls.RowDefinition; $r1.Height = [System.Windows.GridLength]::Auto
    $r2 = New-Object System.Windows.Controls.RowDefinition; $r2.Height = [System.Windows.GridLength]::Auto
    $r3 = New-Object System.Windows.Controls.RowDefinition; $r3.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $onlineGrid.RowDefinitions.Add($r1)
    $onlineGrid.RowDefinitions.Add($r2)
    $onlineGrid.RowDefinitions.Add($r3)

    $searchBarGrid = New-Object System.Windows.Controls.Grid
    $c1 = New-Object System.Windows.Controls.ColumnDefinition; $c1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $c2 = New-Object System.Windows.Controls.ColumnDefinition; $c2.Width = [System.Windows.GridLength]::Auto
    $searchBarGrid.ColumnDefinitions.Add($c1)
    $searchBarGrid.ColumnDefinitions.Add($c2)

    $searchBoxBorder = New-Object System.Windows.Controls.Border
    $searchBoxBorder.Background = $script:win.Resources["ControlBg"]
    $searchBoxBorder.BorderBrush = $script:win.Resources["BorderClr"]
    $searchBoxBorder.BorderThickness = 1
    $searchBoxBorder.CornerRadius = 6
    $searchBoxBorder.Height = 36
    $searchBoxBorder.Margin = "0,0,10,0"

    $txtOnlineSearch = New-Object System.Windows.Controls.TextBox
    $txtOnlineSearch.Background = [System.Windows.Media.Brushes]::Transparent
    $txtOnlineSearch.Foreground = $script:win.Resources["AppText"]
    $txtOnlineSearch.BorderThickness = 0
    $txtOnlineSearch.VerticalAlignment = "Center"
    $txtOnlineSearch.FontSize = 14
    $txtOnlineSearch.Padding = "10,0,10,0"
    $searchBoxBorder.Child = $txtOnlineSearch
    [System.Windows.Controls.Grid]::SetColumn($searchBoxBorder, 0)
    $searchBarGrid.Children.Add($searchBoxBorder) | Out-Null
    $script:txtOnlineSearch = $txtOnlineSearch

    $btnRunOnlineSearch = New-Object System.Windows.Controls.Button
    $btnRunOnlineSearch.Content = "Search WinGet"
    $btnRunOnlineSearch.Height = 36
    $btnRunOnlineSearch.Padding = "16,0,16,0"
    $btnRunOnlineSearch.Style = $script:win.Resources["PrimaryButton"]
    [System.Windows.Controls.Grid]::SetColumn($btnRunOnlineSearch, 1)
    $searchBarGrid.Children.Add($btnRunOnlineSearch) | Out-Null

    [System.Windows.Controls.Grid]::SetRow($searchBarGrid, 0)
    $onlineGrid.Children.Add($searchBarGrid) | Out-Null

    $lblOnlineStatus = New-Object System.Windows.Controls.TextBlock
    $lblOnlineStatus.Text = "Type any package name (e.g. blender, rust, telegram, audacity) and click Search."
    $lblOnlineStatus.FontSize = 12
    $lblOnlineStatus.Opacity = 0.7
    $lblOnlineStatus.Foreground = $script:win.Resources["AppText"]
    $lblOnlineStatus.Margin = "2,6,0,8"
    [System.Windows.Controls.Grid]::SetRow($lblOnlineStatus, 1)
    $onlineGrid.Children.Add($lblOnlineStatus) | Out-Null

    $onlineScroll = New-Object System.Windows.Controls.ScrollViewer
    $onlineScroll.VerticalScrollBarVisibility = "Auto"
    $onlineScroll.FocusVisualStyle = $null

    $onlineResultsWrap = New-Object System.Windows.Controls.WrapPanel
    $onlineResultsWrap.Margin = "0,5,0,5"
    $onlineScroll.Content = $onlineResultsWrap
    [System.Windows.Controls.Grid]::SetRow($onlineScroll, 2)
    $onlineGrid.Children.Add($onlineScroll) | Out-Null

    $onlineTab.Content = $onlineGrid
    $script:tabCats.Items.Add($onlineTab) | Out-Null

    $script:doOnlineSearch = {
        param([string]$query)
        $q = $query.Trim()
        if (-not $q) { return }

        $lblOnlineStatus.Text = "Searching WinGet repository for `"$q`"..."
        $lblOnlineStatus.Opacity = 1.0
        $btnRunOnlineSearch.IsEnabled = $false
        DoEvents

        try {
            $raw = winget search $q --source winget --accept-source-agreements --count 25 2>$null
            $dashLine = $raw | Where-Object { $_ -match '^-{10,}' } | Select-Object -First 1
            $foundApps = @()

            if ($dashLine) {
                $headerLineIndex = [array]::IndexOf($raw, $dashLine) - 1
                if ($headerLineIndex -ge 0) {
                    $header = $raw[$headerLineIndex]
                    $idCol = $header.IndexOf("Id")
                    $verCol = $header.IndexOf("Version")
                    if ($idCol -ge 0) {
                        for ($i = $headerLineIndex + 2; $i -lt $raw.Count; $i++) {
                            $line = $raw[$i]
                            if (-not $line -or $line.Trim().Length -eq 0) { continue }
                            if ($line.Length -le $idCol) { continue }
                            $name = $line.Substring(0, [Math]::Min($line.Length, $idCol)).Trim()
                            $rest = $line.Substring($idCol)
                            $id = ($rest -split '\s+')[0]
                            $version = if ($verCol -gt 0 -and $line.Length -gt $verCol) { ($line.Substring($verCol) -split '\s+')[0] } else { "" }
                            if ($name -and $id) {
                                $foundApps += [PSCustomObject]@{ Name = $name; Id = $id; Version = $version }
                            }
                        }
                    }
                }
            }

            $onlineResultsWrap.Children.Clear()
            if ($foundApps.Count -eq 0) {
                $lblOnlineStatus.Text = "No packages found for `"$q`" in WinGet repository."
                $lblOnlineStatus.Opacity = 0.8
            } else {
                $lblOnlineStatus.Text = "Found $($foundApps.Count) package(s) in WinGet. Select to include in installation."
                $lblOnlineStatus.Opacity = 0.8

                foreach ($item in $foundApps) {
                    $card = New-Object System.Windows.Controls.Border
                    $card.Background = $script:win.Resources["ControlBg"]
                    $card.BorderBrush = $script:win.Resources["BorderClr"]
                    $card.BorderThickness = 1
                    $card.CornerRadius = 6
                    $card.Padding = "8,6,8,6"
                    $card.Margin = "0,0,10,10"
                    $card.Width = 230

                    $cardPanel = New-Object System.Windows.Controls.StackPanel
                    $cardPanel.Orientation = "Vertical"

                    $chk = New-Object System.Windows.Controls.CheckBox
                    $chk.Content = $item.Name
                    $chk.Uid = $item.Id
                    $chk.Margin = "0,0,0,2"
                    
                    $appObj = @{
                        Name = $item.Name
                        Id   = $item.Id
                        Cat  = 99
                        Sel  = $false
                    }
                    $script:registeredApps[$item.Id] = $appObj
                    $script:onlineCheckBoxes += $chk

                    $chk.Add_Checked({ Update-InstallCount })
                    $chk.Add_Unchecked({ Update-InstallCount })
                    $cardPanel.Children.Add($chk) | Out-Null

                    $subText = New-Object System.Windows.Controls.TextBlock
                    $verDisplay = if ($item.Version) { " • v$($item.Version)" } else { "" }
                    $subText.Text = "$($item.Id)$verDisplay"
                    $subText.FontSize = 10
                    $subText.Opacity = 0.6
                    $subText.Margin = "28,0,0,0"
                    $subText.Foreground = $script:win.Resources["AppText"]
                    $subText.TextTrimming = "CharacterEllipsis"
                    $subText.ToolTip = "$($item.Name) ($($item.Id))"
                    $cardPanel.Children.Add($subText) | Out-Null

                    $card.Child = $cardPanel
                    $onlineResultsWrap.Children.Add($card) | Out-Null
                }
            }
        } catch {
            $lblOnlineStatus.Text = "Search error: $_"
            $lblOnlineStatus.Opacity = 1.0
        } finally {
            $btnRunOnlineSearch.IsEnabled = $true
        }
    }

    $btnRunOnlineSearch.Add_Click({
        & $script:doOnlineSearch $script:txtOnlineSearch.Text
    })

    $txtOnlineSearch.Add_KeyDown({
        param($s, $e); $null = $s
        if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
            & $script:doOnlineSearch $script:txtOnlineSearch.Text
        }
    })

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

        $script:txtSearch.Add_KeyDown({
            param($s, $e); $null = $s
            if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
                $q = $script:txtSearch.Text.Trim()
                if ($q) {
                    $script:onlineSearchTab.IsSelected = $true
                    $script:txtOnlineSearch.Text = $q
                    & $script:doOnlineSearch $q
                }
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
        Update-InstallCount
    })

    $script:btnClearAll.Add_Click({
        foreach ($chk in ($script:checkBoxes + $script:onlineCheckBoxes)) { $chk.IsChecked = $false }
        Update-InstallCount
    })

    # Preset save handler with path selection
    $script:btnSave.Add_Click({
        $sel = @()
        foreach ($chk in ($script:checkBoxes + $script:onlineCheckBoxes)) {
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
                    foreach ($chk in ($script:checkBoxes + $script:onlineCheckBoxes)) {
                        $isChecked = $lines -contains $chk.Uid
                        $chk.IsChecked = $isChecked
                        if ($isChecked) { $matchedCount++ }
                    }
                    Update-InstallCount
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
        foreach ($chk in ($script:checkBoxes + $script:onlineCheckBoxes)) {
            if ($chk.IsChecked -eq $true) {
                $uid = $chk.Uid
                if ($script:registeredApps.ContainsKey($uid)) {
                    $toInstall += $script:registeredApps[$uid]
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