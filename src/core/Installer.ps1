# --- WinKit Installation Engine ---

function Start-AppsInstallation($toInstall, $winControls) {
    $TxtLog = $winControls.TxtLog
    $LblProgressTitle = $winControls.LblProgressTitle
    $LblProgress = $winControls.LblProgress
    $PbInstall = $winControls.PbInstall
    $BtnCancelInstall = $winControls.BtnCancelInstall
    $SummaryScroll = $winControls.SummaryScroll
    $SummaryPanel = $winControls.SummaryPanel

    $global:isInstallFinished = $false
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

        $wArgs = "install --exact --id=$($app.Id) --source=winget --silent --disable-interactivity --accept-package-agreements --accept-source-agreements"
        if ($app.Dep -and $global:depCheckBoxes.ContainsKey($app.Name)) {
            $depChk = $global:depCheckBoxes[$app.Name]
            if (-not $depChk.IsChecked) { 
                $wArgs += " --skip-dependencies"
            }
        }

        $useFallback = ($app.Scope -eq "User" -and $global:isAdmin)
        $finalCode = 0

        $tmpOut = "$env:TEMP\winget_out_$($app.Id).log"
        $tmpDone = "$env:TEMP\winget_done_$($app.Id).log"
        $batPath = "$env:TEMP\winget_run_$($app.Id).bat"
        $vbsPath = "$env:TEMP\winget_run_$($app.Id).vbs"

        # Helper to run winget and stream output without blocking the UI thread
        $runWinget = {
            param([bool]$asUserFallback)

            if (Test-Path $tmpOut) { Remove-Item $tmpOut -Force -ErrorAction SilentlyContinue }
            if (Test-Path $tmpDone) { Remove-Item $tmpDone -Force -ErrorAction SilentlyContinue }
            if (Test-Path $batPath) { Remove-Item $batPath -Force -ErrorAction SilentlyContinue }
            if (Test-Path $vbsPath) { Remove-Item $vbsPath -Force -ErrorAction SilentlyContinue }

            $batCmd = "@echo off`r`nwinget $wArgs > `"$tmpOut`" 2>&1`r`necho %ERRORLEVEL% > `"$tmpDone`""
            [System.IO.File]::WriteAllText($batPath, $batCmd, [System.Text.Encoding]::ASCII)

            $procHandle = $null
            if ($asUserFallback) {
                $vbsCmd = "Set WshShell = CreateObject(`"WScript.Shell`")`r`nWshShell.Run chr(34) & `"$batPath`" & Chr(34), 0`r`nSet WshShell = Nothing"
                [System.IO.File]::WriteAllText($vbsPath, $vbsCmd, [System.Text.Encoding]::ASCII)
                Start-Process "explorer.exe" -ArgumentList "`"$vbsPath`""
            } else {
                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = "cmd.exe"
                $psi.Arguments = "/c `"$batPath`""
                $psi.CreateNoWindow = $true
                $psi.UseShellExecute = $false
                $procHandle = [System.Diagnostics.Process]::Start($psi)
            }

            $fs = $null
            $sr = $null
            $lastPos = 0
            $lastProgressUpdate = [DateTime]::MinValue
            $isDownloading = $false
            $lastProgText = ""
            $progressAppended = $false
            $progressStartPos = 0
            $dlTotalBytes = 0

            while (-not (Test-Path $tmpDone)) {
                if ($global:cancelInstall) {
                    if ($null -ne $procHandle) {
                        try {
                            Start-Process "taskkill.exe" -ArgumentList "/F /T /PID $($procHandle.Id)" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                        } catch { $null = $_ }
                    }
                    Get-Process -Name "winget" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    break
                }

                if (Test-Path $tmpOut) {
                    try {
                        $fs = New-Object System.IO.FileStream($tmpOut, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                        if ($fs.Length -gt $lastPos) {
                            $fs.Seek($lastPos, [System.IO.SeekOrigin]::Begin) | Out-Null
                            $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
                            $chunk = $sr.ReadToEnd()
                            $lastPos = $fs.Position
                            $sr.Close()
                            $fs.Close()

                            if ($chunk) {
                                $TxtLog.AppendText($chunk)
                                $script:currentAppLog += $chunk
                                $TxtLog.ScrollToEnd()
                                try { [Console]::Write($chunk) } catch { $null = $_ }

                                if ($chunk -match "(?i)Downloading\s+(https?://[^\s]+)") {
                                    $isDownloading = $true
                                    $progressAppended = $false
                                    $lastProgText = ""
                                    $dlTotalBytes = 0
                                }

                                if ($chunk -match "(\d+(?:\.\d+)?\s*[KMG]B\s*/\s*\d+(?:\.\d+)?\s*[KMG]B|\d+\s*%)") {
                                    $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name) - $($matches[1])"
                                }

                                if ($chunk -match "(?i)(Successfully verified|Starting package install|Успешно проверен|Установка пакета)") {
                                    if ($isDownloading -and $progressAppended) {
                                        $TxtLog.AppendText("`n")
                                        $TxtLog.ScrollToEnd()
                                    }
                                    $isDownloading = $false
                                    $PbInstall.IsIndeterminate = $true
                                    $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name)"
                                }
                            }
                        }
                    } catch { $null = $_ }
                }

                # Update progress bar if downloading (throttled to 250ms)
                if ($isDownloading) {
                    $now = [DateTime]::UtcNow
                    if (($now - $lastProgressUpdate).TotalMilliseconds -ge 250) {
                        $lastProgressUpdate = $now
                        $currBytes = 0
                        try {
                            $dlDirs = Get-ChildItem -Path "$env:TEMP\WinGet", "$env:LOCALAPPDATA\Temp\WinGet" -Filter "*$($app.Id)*" -Directory -ErrorAction SilentlyContinue
                            if ($dlDirs) {
                                $dlFiles = Get-ChildItem -Path $dlDirs.FullName -File -ErrorAction SilentlyContinue
                                if ($dlFiles) {
                                    $currBytes = ($dlFiles | Measure-Object -Property Length -Sum).Sum
                                }
                            }
                        } catch { $null = $_ }

                        if ($currBytes -gt 0) {
                            $currMB = [Math]::Round($currBytes / 1MB, 1)
                            $progStr = "$currMB MB"
                            if ($dlTotalBytes -gt 0) {
                                $totMB = [Math]::Round($dlTotalBytes / 1MB, 1)
                                $pct = [Math]::Min(100, [Math]::Max(0, [Math]::Round(($currBytes / $dlTotalBytes) * 100)))
                                $progStr = "$currMB MB / $totMB MB ($pct%)"
                                $PbInstall.IsIndeterminate = $false
                                $PbInstall.Value = $pct
                            }

                            $LblProgress.Text = "Installing ($count / $($toInstall.Count)): $($app.Name) - $progStr"

                            if ($progStr -ne $lastProgText) {
                                $lastProgText = $progStr
                                $barLen = 20
                                if ($dlTotalBytes -gt 0) {
                                    $f = [Math]::Floor(($pct / 100) * $barLen)
                                    $e = $barLen - $f
                                    $bar = ("█" * $f) + ("░" * $e)
                                    $pLine = "  $bar  $progStr"
                                } else {
                                    $pLine = "  Downloading: $progStr"
                                }

                                if (-not $progressAppended) {
                                    $progressStartPos = $TxtLog.Text.Length
                                    $TxtLog.AppendText("`n" + $pLine)
                                    $progressAppended = $true
                                } else {
                                    $curTxt = $TxtLog.Text
                                    if ($curTxt.Length -ge $progressStartPos) {
                                        $TxtLog.Text = $curTxt.Substring(0, $progressStartPos) + "`n" + $pLine
                                    }
                                }
                                $TxtLog.ScrollToEnd()
                            }
                        }
                    }
                }

                DoEvents
                Start-Sleep -Milliseconds 40
                Start-Sleep -Milliseconds 15
            }

            # Drain any remaining bytes from the log file
            if (Test-Path $tmpOut) {
                try {
                    $fs = New-Object System.IO.FileStream($tmpOut, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                    if ($fs.Length -gt $lastPos) {
                        $fs.Seek($lastPos, [System.IO.SeekOrigin]::Begin) | Out-Null
                        $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
                        $remText = $sr.ReadToEnd()
                        $sr.Close()
                        if ($remText) {
                            $TxtLog.AppendText($remText)
                            $script:currentAppLog += $remText
                            $TxtLog.ScrollToEnd()
                            try { [Console]::Write($remText) } catch { $null = $_ }
                        }
                    }
                    $fs.Close()
                } catch { $null = $_ }
            }

            $retCode = -1
            if (Test-Path $tmpDone) {
                try {
                    $retCode = (Get-Content $tmpDone -Raw).Trim() -as [int]
                } catch { $null = $_ }
            }
            return $retCode
        }

        $script:currentAppLog = ""
        if (-not $useFallback) {
            $finalCode = & $runWinget $false

            if ($script:currentAppLog -match "cannot be run from an administrator context" -and -not $global:cancelInstall) {
                $TxtLog.AppendText("`n[!] Administrator block detected. Retrying as normal user in background...`n")
                $TxtLog.ScrollToEnd()
                Write-Host "Admin block detected for $($app.Name). Retrying via explorer.exe..." -ForegroundColor Yellow
                $useFallback = $true
            }
        }

        if ($useFallback -and -not $global:cancelInstall) {
            $finalCode = & $runWinget $true
        }

        $appLog = $script:currentAppLog

        # Cleanup temporary runner files
        Remove-Item $tmpOut, $tmpDone, $batPath, $vbsPath -Force -ErrorAction SilentlyContinue

        if (-not $global:cancelInstall) {
            # Bundled bloatware cleanup & background downloader eradication
            if ($wArgs -match "--skip-dependencies") {
                if ($app.Name -eq "TeamSpeak 3") {
                    $TxtLog.AppendText("`n[+] Ensuring bundled Overwolf is removed...`n")
                    $TxtLog.ScrollToEnd()
                    DoEvents
                    
                    # 1. Kill background NSIS downloader stub and active Overwolf processes
                    Get-Process -Name "Un_A", "Overwolf*", "OWClient*", "OWLauncher*" -ErrorAction SilentlyContinue | Stop-Process -Force
                    
                    # 2. Wipe temporary background extraction directories
                    Remove-Item "$env:TEMP\~nsu*.tmp", "$env:LOCALAPPDATA\Temp\~nsu*.tmp" -Recurse -Force -ErrorAction SilentlyContinue
                    
                    # 3. Clean uninstallation if registered
                    Start-Process "winget" -ArgumentList "uninstall --exact --id Overwolf.Overwolf --silent --accept-source-agreements" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                    if (Test-Path "C:\Program Files (x86)\Overwolf\OWUninstaller.exe") {
                        Start-Process "C:\Program Files (x86)\Overwolf\OWUninstaller.exe" -ArgumentList "/silent" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                    }
                    
                    # 4. Clean leftover persistence directories and registry keys
                    Remove-Item "C:\Program Files (x86)\Overwolf", "$env:LOCALAPPDATA\Overwolf", "$env:APPDATA\Overwolf" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item "HKCU:\Software\OverwolfPersist", "HKLM:\Software\WOW6432Node\OverwolfPersist" -Recurse -Force -ErrorAction SilentlyContinue
                }
                if ($app.Name -eq "MSI Afterburner") {
                    $TxtLog.AppendText("`n[+] Removing bundled RivaTuner...`n")
                    $TxtLog.ScrollToEnd()
                    DoEvents
                    Start-Process "winget" -ArgumentList "uninstall --exact --id Guru3D.RTSS --silent --accept-source-agreements" -Wait -NoNewWindow -ErrorAction SilentlyContinue
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
        $code = $res.Code
        $logStr = $res.Log
        
        # 1. Already installed (no updates needed)
        $alreadyInstalledCodes = @(-1978335220, 2316632076, -1978335189, 2316632107, -1978335187, 2316632109, -1978335190, 2316632106)
        $alreadyInstalledRegex = "(?i)(No (?:newer|available|applicable) (?:package|upgrade|update)|найден.*установленный пакет.*не найдено|не найдено.*обновлен|не найдено.*верси|уже установлен|установлена последняя версия|already installed.*no (?:newer|available|upgrade))"
        $isInstalledNoUpdate = ($code -in $alreadyInstalledCodes -or ($logStr -match $alreadyInstalledRegex -and -not ($logStr -match "(?i)(Successfully installed|Успешно установлен)")))

        # 2. Updated / Upgraded
        $isUpgradeAttempt = ($logStr -match "(?i)(Trying to upgrade|попытка обновить|Upgrading|Обновление пакета)")
        $isSuccess = ($code -eq 0 -or $code -eq 3010 -or $code -eq 1641 -or ($logStr -match "(?i)(Successfully installed|Успешно установлен)"))
        $isUpdated = ($isUpgradeAttempt -and $isSuccess -and -not $isInstalledNoUpdate)
        
        switch ($true) {
            { $res.Cancelled } {
                $statusColor = "#FFA500" # Orange
                $statusText = "Cancelled"
                $statusDesc = "Installation was cancelled by the user."
            }
            { $isInstalledNoUpdate } {
                $statusColor = "#00BCF9" # Neutral Cyan
                $statusText = "Already installed (Up to date)"
                $statusDesc = "The latest version is already installed on your system."
            }
            { $isUpdated } {
                $statusColor = "#FFC83B" # Neutral Yellow
                $statusText = "Successfully updated"
                $statusDesc = "Application was updated to the newest available release."
            }
            { $isSuccess } {
                $statusColor = "#107C41" # Green
                $statusText = "Installed successfully"
                $statusDesc = "Completed with exit code $code."
            }
            default {
                $statusColor = "#E81123" # Red
                $statusText = "Installation failed"
                $statusDesc = "Installer returned error code $code."
            }
        }

        # Build Card Container
        $card = New-Object System.Windows.Controls.Border
        $card.Background = $global:win.Resources["ControlBg"]
        $card.BorderBrush = $global:win.Resources["BorderClr"]
        $card.BorderThickness = 1
        $card.CornerRadius = 6
        $card.Margin = "0,0,0,10"
        $card.Padding = "12,10,12,10"

        $cardGrid = New-Object System.Windows.Controls.Grid
        $col1 = New-Object System.Windows.Controls.ColumnDefinition; $col1.Width = [System.Windows.GridLength]::Auto
        $col2 = New-Object System.Windows.Controls.ColumnDefinition; $col2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $col3 = New-Object System.Windows.Controls.ColumnDefinition; $col3.Width = [System.Windows.GridLength]::Auto
        $cardGrid.ColumnDefinitions.Add($col1)
        $cardGrid.ColumnDefinitions.Add($col2)
        $cardGrid.ColumnDefinitions.Add($col3)

        $rowTop = New-Object System.Windows.Controls.RowDefinition; $rowTop.Height = [System.Windows.GridLength]::Auto
        $rowBot = New-Object System.Windows.Controls.RowDefinition; $rowBot.Height = [System.Windows.GridLength]::Auto
        $cardGrid.RowDefinitions.Add($rowTop)
        $cardGrid.RowDefinitions.Add($rowBot)

        # Status Circle Indicator
        $statusDot = New-Object System.Windows.Shapes.Ellipse
        $statusDot.Width = 10
        $statusDot.Height = 10
        $statusDot.Fill = $global:brushConverter.ConvertFromString($statusColor)
        $statusDot.VerticalAlignment = "Center"
        $statusDot.Margin = "4,0,12,0"
        [System.Windows.Controls.Grid]::SetColumn($statusDot, 0)
        [System.Windows.Controls.Grid]::SetRow($statusDot, 0)
        $cardGrid.Children.Add($statusDot) | Out-Null

        # App Info (Name & Status Description)
        $titlePanel = New-Object System.Windows.Controls.StackPanel
        $titlePanel.Orientation = "Vertical"
        $titlePanel.VerticalAlignment = "Center"
        [System.Windows.Controls.Grid]::SetColumn($titlePanel, 1)
        [System.Windows.Controls.Grid]::SetRow($titlePanel, 0)

        $appName = New-Object System.Windows.Controls.TextBlock
        $appName.Text = $res.App.Name
        $appName.FontSize = 14
        $appName.FontWeight = [System.Windows.FontWeights]::SemiBold
        $appName.Foreground = $global:win.Resources["AppText"]
        $titlePanel.Children.Add($appName) | Out-Null

        $appSub = New-Object System.Windows.Controls.TextBlock
        $appSub.Text = "$statusText - $statusDesc"
        $appSub.FontSize = 12
        $appSub.Foreground = $global:brushConverter.ConvertFromString($statusColor)
        $titlePanel.Children.Add($appSub) | Out-Null

        $cardGrid.Children.Add($titlePanel) | Out-Null

        # Detailed Log Dropdown Panel
        $logContainer = New-Object System.Windows.Controls.Border
        $logContainer.Background = $global:brushConverter.ConvertFromString("#181818")
        $logContainer.BorderThickness = 0
        $logContainer.CornerRadius = 4
        $logContainer.Margin = "0,10,0,0"
        $logContainer.Padding = "8"
        $logContainer.Visibility = "Collapsed"
        [System.Windows.Controls.Grid]::SetColumn($logContainer, 0)
        [System.Windows.Controls.Grid]::SetColumnSpan($logContainer, 3)
        [System.Windows.Controls.Grid]::SetRow($logContainer, 1)

        $logBox = New-Object System.Windows.Controls.TextBox
        $logBox.Text = if ($res.Log) { $res.Log } else { "No output captured." }
        $logBox.Background = [System.Windows.Media.Brushes]::Transparent
        $logBox.Foreground = $global:brushConverter.ConvertFromString("#AAAAAA")
        $logBox.FontFamily = "Consolas"
        $logBox.FontSize = 11
        $logBox.IsReadOnly = $true
        $logBox.TextWrapping = "Wrap"
        $logBox.BorderThickness = 0
        $logBox.MaxHeight = 150
        $logBox.VerticalScrollBarVisibility = "Auto"
        $logContainer.Child = $logBox

        $cardGrid.Children.Add($logContainer) | Out-Null

        # Show / Hide Log Button
        $btnLog = New-Object System.Windows.Controls.Button
        $btnLog.Content = "Show Log"
        $btnLog.FontSize = 11
        $btnLog.Padding = "10,4,10,4"
        $btnLog.Height = 26
        $btnLog.VerticalAlignment = "Center"
        $btnLog.Tag = $logContainer
        [System.Windows.Controls.Grid]::SetColumn($btnLog, 2)
        [System.Windows.Controls.Grid]::SetRow($btnLog, 0)

        $global:allLogControls += @{ Button = $btnLog; Container = $logContainer }

        $btnLog.Add_Click({
            $target = $this.Tag
            if ($null -ne $target) {
                if ($target.Visibility -eq "Visible") {
                    $target.Visibility = "Collapsed"
                    $this.Content = "Show Log"
                } else {
                    $target.Visibility = "Visible"
                    $this.Content = "Hide Log"
                }
            }
        })

        $cardGrid.Children.Add($btnLog) | Out-Null
        $card.Child = $cardGrid
        $SummaryPanel.Children.Add($card) | Out-Null
    }

    $global:isInstallFinished = $true
    $BtnCancelInstall.Content = "Close"
    $BtnCancelInstall.IsEnabled = $true
}
