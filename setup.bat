@echo off
chcp 65001 >nul

:: ===============================================================
::  WinKit - quick app installer powered by WinGet
::  GitHub: https://github.com/Refyrd/WinKit
:: ===============================================================

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
title WinKit - App Installer
mode con cols=58 lines=25

:: --- Colors ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "R=%ESC%[0m"
set "CC=%ESC%[96m"
set "CG=%ESC%[92m"
set "CY=%ESC%[93m"
set "CR=%ESC%[91m"
set "CD=%ESC%[90m"
set "CW=%ESC%[97m"
set "CB=%ESC%[1m"

:: --- App List ---
set "TOTAL=20"
set "PAGES=5"

set "N1=Google Chrome"       & set "I1=Google.Chrome"              & set "P1=1"
set "N2=Mozilla Firefox"     & set "I2=Mozilla.Firefox"            & set "P2=1"
set "N3=Brave Browser"       & set "I3=Brave.Brave"               & set "P3=1"
set "N4=Visual Studio Code"  & set "I4=Microsoft.VisualStudioCode" & set "P4=2"
set "N5=Git"                 & set "I5=Git.Git"                    & set "P5=2"
set "N6=Python 3"            & set "I6=Python.Python.3.12"         & set "P6=2"
set "N7=Node.js LTS"         & set "I7=OpenJS.NodeJS.LTS"          & set "P7=2"
set "N8=Notepad++"           & set "I8=Notepad++.Notepad++"        & set "P8=2"
set "N9=Steam"               & set "I9=Valve.Steam"                & set "P9=3"
set "N10=Discord"            & set "I10=Discord.Discord"           & set "P10=3"
set "N11=Telegram"           & set "I11=Telegram.TelegramDesktop"  & set "P11=3"
set "N12=VLC Media Player"   & set "I12=VideoLAN.VLC"              & set "P12=4"
set "N13=Spotify"            & set "I13=Spotify.Spotify"           & set "P13=4"
set "N14=OBS Studio"         & set "I14=OBSProject.OBSStudio"      & set "P14=4"
set "N15=7-Zip"              & set "I15=7zip.7zip"                 & set "P15=5"
set "N16=WinRAR"             & set "I16=RARLab.WinRAR"             & set "P16=5"
set "N17=qBittorrent"        & set "I17=qBittorrent.qBittorrent"   & set "P17=5"
set "N18=MSI Afterburner"    & set "I18=Guru3D.Afterburner"        & set "P18=5"
set "N19=PowerToys"          & set "I19=Microsoft.PowerToys"       & set "P19=5"
set "N20=Everything Search"  & set "I20=voidtools.Everything"      & set "P20=5"

set "CAT1=Browsers"
set "CAT2=Development"
set "CAT3=Gaming / Social"
set "CAT4=Media"
set "CAT5=Utilities"

:: --- Initialize ---
for /L %%i in (1,1,%TOTAL%) do set "S%%i=0"
set "CUR_PAGE=1"

:: ===============================================================
::  MAIN MENU
:: ===============================================================
:menu
cls
echo.
echo  %CC%========================================================%R%
echo  %CC%#%CB%%CW%           WinKit - App Installer                  %R%%CC%#%R%
echo  %CC%========================================================%R%
echo.

:: --- Page indicator ---
set "_nav="
for /L %%p in (1,1,%PAGES%) do (
    if %%p==%CUR_PAGE% (
        set "_nav=!_nav! %CB%%CW%[%%p]%R%"
    ) else (
        set "_nav=!_nav! %CD%%%p%R%"
    )
)
echo   %CC%^<%R%!_nav! %CC%^>%R%
echo.

:: --- Category title ---
call :show_cat_title
echo.

:: --- Show items for current page ---
for /L %%i in (1,1,%TOTAL%) do (
    if "!P%%i!"=="%CUR_PAGE%" call :print_item %%i
)

:: --- Count selected ---
set "SC=0"
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" set /a SC+=1

echo.
echo  %CC%--------------------------------------------------------%R%
echo   %CW%Selected: %CG%!SC!%CW% of %TOTAL%%R%
echo  %CC%--------------------------------------------------------%R%
echo.
echo   %CD%^< ^>%CW% pages  %CD%nums%CW% toggle  %CG%A%CW% all  %CY%C%CW% clear%R%
echo   %CG%D%CW% install  %CR%0%CW% exit%R%
echo.
set "input="
set /p "input=  %CC%^> %R%"

if not defined input goto menu
if /i "!input!"=="0" exit
if /i "!input!"=="D" goto confirm

:: --- Page navigation ---
if "!input!"=="." goto next_page
if "!input!"==">" goto next_page
if "!input!"=="," goto prev_page
if "!input!"=="<" goto prev_page

:: --- Select all ---
if /i "!input!"=="A" (
    for /L %%i in (1,1,%TOTAL%) do set "S%%i=1"
    goto menu
)

:: --- Clear ---
if /i "!input!"=="C" (
    for /L %%i in (1,1,%TOTAL%) do set "S%%i=0"
    goto menu
)

:: --- Toggle items ---
for %%n in (!input!) do (
    set "_ok=0"
    for /L %%i in (1,1,%TOTAL%) do (
        if "%%n"=="%%i" (
            set "_ok=1"
            if "!S%%i!"=="0" (set "S%%i=1") else (set "S%%i=0")
        )
    )
)
goto menu

:next_page
if %CUR_PAGE% lss %PAGES% set /a CUR_PAGE+=1
goto menu

:prev_page
if %CUR_PAGE% gtr 1 set /a CUR_PAGE-=1
goto menu

:: ===============================================================
::  CONFIRM
:: ===============================================================
:confirm
set "SC=0"
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" set /a SC+=1

if !SC! equ 0 (
    echo  %CR%No apps selected!%R%
    timeout /t 2 >nul
    goto menu
)

cls
echo.
echo  %CC%========================================================%R%
echo  %CC%#%CB%%CW%            Confirm Installation                   %R%%CC%#%R%
echo  %CC%========================================================%R%
echo.
echo   %CG%Will install !SC! app(s):%R%
echo.
for /L %%i in (1,1,%TOTAL%) do (
    if "!S%%i!"=="1" echo     %CW%- !N%%i!  %CD%[!I%%i!]%R%
)
echo.
echo  %CC%--------------------------------------------------------%R%
echo.
echo   %CW%1. Start   2. Go back   3. Exit%R%
echo.
set "input="
set /p "input=  %CC%^> %R%"

if "!input!"=="1" goto install
if "!input!"=="2" goto menu
if "!input!"=="3" exit
echo  %CR%  Invalid input.%R%
goto confirm

:: ===============================================================
::  INSTALL
:: ===============================================================
:install
mode con cols=80 lines=30
cls
echo.
echo  %CC%========================================================%R%
echo  %CC%#%CB%%CW%            Installing apps...                     %R%%CC%#%R%
echo  %CC%========================================================%R%
echo.

set "DONE=0"
set "OK=0"
set "FAIL=0"

for /L %%i in (1,1,%TOTAL%) do (
    if "!S%%i!"=="1" (
        set /a DONE+=1
        echo  %CC%--------------------------------------------------------%R%
        echo   %CW%[!DONE!/!SC!] Installing: %CY%!N%%i!%R%
        echo   %CD%Package: !I%%i!%R%
        echo  %CC%--------------------------------------------------------%R%
        echo.
        winget install --id !I%%i! -e --source winget --accept-package-agreements --accept-source-agreements
        call :check_result %%i
        echo.
    )
)

:: ===============================================================
::  RESULTS
:: ===============================================================
echo.
echo  %CC%========================================================%R%
echo  %CC%#%CB%%CW%            Installation Results                   %R%%CC%#%R%
echo  %CC%========================================================%R%
echo.
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" echo     !RES%%i!
echo.
echo  %CC%--------------------------------------------------------%R%
echo   %CG%OK: !OK!%R%  ^|  %CR%Failed: !FAIL!%R%  ^|  %CW%Total: !SC!%R%
echo  %CC%--------------------------------------------------------%R%
echo.
echo  Press any key to exit...
pause >nul
exit

:: ===============================================================
::  SUBROUTINES
:: ===============================================================

:show_cat_title
echo   %CY%[ !CAT%CUR_PAGE%! ]%R%
goto :eof

:print_item
set "_i=%1"
set "_pad=  "
if %_i% geq 10 set "_pad= "
if "!S%_i%!"=="1" (
    echo     %CG%%_pad%%_i%. [x] !N%_i%!%R%
) else (
    echo      %_pad%%_i%. [ ] !N%_i%!
)
goto :eof

:check_result
if !errorlevel! equ 0 (
    set /a OK+=1
    set "RES%1=  %CG%[OK]%R%  !N%1!"
    echo   %CG%OK: !N%1!%R%
) else (
    set /a FAIL+=1
    set "RES%1=  %CR%[FAIL]%R%  !N%1!"
    echo   %CR%FAIL: !N%1!%R%
)
goto :eof