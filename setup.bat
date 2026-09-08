@echo off
chcp 65001 >nul

:: ═══════════════════════════════════════════════════════════════
::  WinKit — quick app installer powered by WinGet
::  GitHub: https://github.com/Refyrd/WinKit
:: ═══════════════════════════════════════════════════════════════

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0"""" admin", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

if "%1"=="admin" cd /d "%~dp0"

setlocal EnableDelayedExpansion
title WinKit — App Installer

:: ─── Colors ───
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_RESET=%ESC%[0m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_RED=%ESC%[91m"
set "C_GRAY=%ESC%[90m"
set "C_WHITE=%ESC%[97m"
set "C_BOLD=%ESC%[1m"

:: ─── App List ───
:: Format: NAME_N=Display name | ID_N=WinGet ID | CAT_N=Category
:: To add a new app: add NAME_, ID_, CAT_ lines and increase TOTAL
set "TOTAL=20"

:: ── Browsers ──
set "NAME_1=Google Chrome"
set "ID_1=Google.Chrome"
set "CAT_1=Browsers"

set "NAME_2=Mozilla Firefox"
set "ID_2=Mozilla.Firefox"
set "CAT_2=Browsers"

set "NAME_3=Brave Browser"
set "ID_3=Brave.Brave"
set "CAT_3=Browsers"

:: ── Development ──
set "NAME_4=Visual Studio Code"
set "ID_4=Microsoft.VisualStudioCode"
set "CAT_4=Development"

set "NAME_5=Git"
set "ID_5=Git.Git"
set "CAT_5=Development"

set "NAME_6=Python 3"
set "ID_6=Python.Python.3.12"
set "CAT_6=Development"

set "NAME_7=Node.js LTS"
set "ID_7=OpenJS.NodeJS.LTS"
set "CAT_7=Development"

set "NAME_8=Notepad++"
set "ID_8=Notepad++.Notepad++"
set "CAT_8=Development"

:: ── Gaming ^& Social ──
set "NAME_9=Steam"
set "ID_9=Valve.Steam"
set "CAT_9=Gaming ^& Social"

set "NAME_10=Discord"
set "ID_10=Discord.Discord"
set "CAT_10=Gaming ^& Social"

set "NAME_11=Telegram"
set "ID_11=Telegram.TelegramDesktop"
set "CAT_11=Gaming ^& Social"

:: ── Media ──
set "NAME_12=VLC Media Player"
set "ID_12=VideoLAN.VLC"
set "CAT_12=Media"

set "NAME_13=Spotify"
set "ID_13=Spotify.Spotify"
set "CAT_13=Media"

set "NAME_14=OBS Studio"
set "ID_14=OBSProject.OBSStudio"
set "CAT_14=Media"

:: ── Utilities ──
set "NAME_15=7-Zip"
set "ID_15=7zip.7zip"
set "CAT_15=Utilities"

set "NAME_16=WinRAR"
set "ID_16=RARLab.WinRAR"
set "CAT_16=Utilities"

set "NAME_17=qBittorrent"
set "ID_17=qBittorrent.qBittorrent"
set "CAT_17=Utilities"

set "NAME_18=MSI Afterburner"
set "ID_18=Guru3D.Afterburner"
set "CAT_18=Utilities"

set "NAME_19=PowerToys"
set "ID_19=Microsoft.PowerToys"
set "CAT_19=Utilities"

set "NAME_20=Everything Search"
set "ID_20=voidtools.Everything"
set "CAT_20=Utilities"

:: ─── Initialize selection ───
for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=0"

:: ═══════════════════════════════════════════════════════════════
::  MAIN MENU
:: ═══════════════════════════════════════════════════════════════
:main_menu
cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%             WinKit — App Installer                    %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

:: Display apps by category
set "LAST_CAT="
for /L %%i in (1,1,%TOTAL%) do (
    if not "!CAT_%%i!"=="!LAST_CAT!" (
        echo   %C_YELLOW%[!CAT_%%i!]%C_RESET%
        set "LAST_CAT=!CAT_%%i!"
    )
    if "!SEL_%%i!"=="1" (
        if %%i lss 10 (
            echo     %C_GREEN%  %%i. [■] !NAME_%%i!%C_RESET%
        ) else (
            echo     %C_GREEN% %%i. [■] !NAME_%%i!%C_RESET%
        )
    ) else (
        if %%i lss 10 (
            echo       %%i. [ ] !NAME_%%i!
        ) else (
            echo      %%i. [ ] !NAME_%%i!
        )
    )
)

:: Count selected
set "SEL_COUNT=0"
for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" set /a SEL_COUNT+=1
)

echo.
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo   %C_WHITE%Selected: %C_GREEN%!SEL_COUNT!%C_WHITE% of %TOTAL%%C_RESET%
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo.
echo   %C_WHITE%Enter numbers separated by spaces %C_GRAY%(e.g. 1 3 5 7)%C_RESET%
echo   %C_GREEN%A%C_WHITE% — select all  %C_YELLOW%C%C_WHITE% — clear selection%C_RESET%
echo   %C_GREEN%D%C_WHITE% — start install  %C_RED%0%C_WHITE% — exit%C_RESET%
echo.
set "input="
set /p "input=  %C_CYAN%^> %C_RESET%"

:: Empty input
if not defined input goto main_menu

:: Exit
if /i "%input%"=="0" (
    echo.
    echo  %C_GRAY%Exiting...%C_RESET%
    timeout /t 1 >nul
    exit
)

:: Select all
if /i "%input%"=="A" (
    for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=1"
    goto main_menu
)

:: Clear selection
if /i "%input%"=="C" (
    for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=0"
    goto main_menu
)

:: Start install
if /i "%input%"=="D" goto confirm_phase

:: Process numbers (toggle)
for %%n in (%input%) do (
    set "VALID=0"
    for /L %%i in (1,1,%TOTAL%) do (
        if "%%n"=="%%i" (
            set "VALID=1"
            if "!SEL_%%i!"=="0" (
                set "SEL_%%i=1"
            ) else (
                set "SEL_%%i=0"
            )
        )
    )
    if "!VALID!"=="0" (
        echo  %C_RED%  Invalid number: %%n%C_RESET%
        timeout /t 1 >nul
    )
)
goto main_menu

:: ═══════════════════════════════════════════════════════════════
::  CONFIRMATION
:: ═══════════════════════════════════════════════════════════════
:confirm_phase

:: Count selected
set "SEL_COUNT=0"
for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" set /a SEL_COUNT+=1
)

if !SEL_COUNT! equ 0 (
    echo.
    echo  %C_RED%No apps selected!%C_RESET%
    timeout /t 2 >nul
    goto main_menu
)

cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%              Confirm Installation                     %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.
echo   %C_GREEN%The following apps will be installed (!SEL_COUNT!):%C_RESET%
echo.

for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" (
        echo     %C_WHITE%• !NAME_%%i!  %C_GRAY%(!ID_%%i!)%C_RESET%
    )
)

echo.
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo.

:ask_confirm
echo   %C_WHITE%1. Start installation%C_RESET%
echo   %C_WHITE%2. Go back to selection%C_RESET%
echo   %C_WHITE%3. Cancel and exit%C_RESET%
echo.
set "input="
set /p "input=  %C_CYAN%^> %C_RESET%"

if "%input%"=="1" goto install_phase
if "%input%"=="2" goto main_menu
if "%input%"=="3" (
    echo.
    echo  %C_GRAY%Installation cancelled. Exiting...%C_RESET%
    timeout /t 2 >nul
    exit
)

echo  %C_RED%  Invalid input. Try again.%C_RESET%
goto ask_confirm

:: ═══════════════════════════════════════════════════════════════
::  INSTALLATION
:: ═══════════════════════════════════════════════════════════════
:install_phase
cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%              Installing apps...                       %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

set "DONE=0"
set "OK=0"
set "FAIL=0"

for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" (
        set /a DONE+=1
        echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
        echo   %C_WHITE%[!DONE!/!SEL_COUNT!] Installing: %C_YELLOW%!NAME_%%i!%C_RESET%
        echo   %C_GRAY%Package: !ID_%%i!%C_RESET%
        echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
        echo.

        winget install --id !ID_%%i! -e --source winget --accept-package-agreements --accept-source-agreements

        if !errorlevel! equ 0 (
            set /a OK+=1
            set "RES_%%i=%C_GREEN%✓ Success%C_RESET%"
            echo.
            echo   %C_GREEN%✓ !NAME_%%i! — installed successfully%C_RESET%
        ) else (
            set /a FAIL+=1
            set "RES_%%i=%C_RED%✗ Failed%C_RESET%"
            echo.
            echo   %C_RED%✗ !NAME_%%i! — installation failed%C_RESET%
        )
        echo.
    )
)

:: ═══════════════════════════════════════════════════════════════
::  RESULTS
:: ═══════════════════════════════════════════════════════════════
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%              Installation Results                     %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" (
        echo     !RES_%%i!  —  !NAME_%%i!
    )
)

echo.
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo   %C_GREEN%Success: !OK!%C_RESET%  │  %C_RED%Failed: !FAIL!%C_RESET%  │  %C_WHITE%Total: !SEL_COUNT!%C_RESET%
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo.
echo  Press any key to exit...
pause >nul
exit