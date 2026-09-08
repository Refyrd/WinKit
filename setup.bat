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

set "N1=Google Chrome"       & set "I1=Google.Chrome"              & set "G1=1"
set "N2=Mozilla Firefox"     & set "I2=Mozilla.Firefox"            & set "G2=1"
set "N3=Brave Browser"       & set "I3=Brave.Brave"               & set "G3=1"
set "N4=Visual Studio Code"  & set "I4=Microsoft.VisualStudioCode" & set "G4=2"
set "N5=Git"                 & set "I5=Git.Git"                    & set "G5=2"
set "N6=Python 3"            & set "I6=Python.Python.3.12"         & set "G6=2"
set "N7=Node.js LTS"         & set "I7=OpenJS.NodeJS.LTS"          & set "G7=2"
set "N8=Notepad++"           & set "I8=Notepad++.Notepad++"        & set "G8=2"
set "N9=Steam"               & set "I9=Valve.Steam"                & set "G9=3"
set "N10=Discord"            & set "I10=Discord.Discord"           & set "G10=3"
set "N11=Telegram"           & set "I11=Telegram.TelegramDesktop"  & set "G11=3"
set "N12=VLC Media Player"   & set "I12=VideoLAN.VLC"              & set "G12=4"
set "N13=Spotify"            & set "I13=Spotify.Spotify"           & set "G13=4"
set "N14=OBS Studio"         & set "I14=OBSProject.OBSStudio"      & set "G14=4"
set "N15=7-Zip"              & set "I15=7zip.7zip"                 & set "G15=5"
set "N16=WinRAR"             & set "I16=RARLab.WinRAR"             & set "G16=5"
set "N17=qBittorrent"        & set "I17=qBittorrent.qBittorrent"   & set "G17=5"
set "N18=MSI Afterburner"    & set "I18=Guru3D.Afterburner"        & set "G18=5"
set "N19=PowerToys"          & set "I19=Microsoft.PowerToys"       & set "G19=5"
set "N20=Everything Search"  & set "I20=voidtools.Everything"      & set "G20=5"

set "CAT1=Browsers"
set "CAT2=Development"
set "CAT3=Gaming / Social"
set "CAT4=Media"
set "CAT5=Utilities"

:: --- Initialize ---
for /L %%i in (1,1,%TOTAL%) do set "S%%i=0"

:: ===============================================================
::  MAIN MENU
:: ===============================================================
:menu
cls
echo.
echo  %CC%============================================================%R%
echo  %CC%#%CB%%CW%             WinKit - App Installer                    %R%%CC%#%R%
echo  %CC%============================================================%R%
echo.

set "LAST_G="
for /L %%i in (1,1,%TOTAL%) do (
    if not "!G%%i!"=="!LAST_G!" (
        set "LAST_G=!G%%i!"
        call :print_cat !G%%i!
    )
    call :print_item %%i
)

set "SC=0"
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" set /a SC+=1

echo.
echo  %CC%------------------------------------------------------------%R%
echo   %CW%Selected: %CG%!SC!%CW% of %TOTAL%%R%
echo  %CC%------------------------------------------------------------%R%
echo.
echo   %CW%Enter numbers separated by spaces %CD%(e.g. 1 3 5 7)%R%
echo   %CG%A%CW% - select all   %CY%C%CW% - clear   %CG%D%CW% - install   %CR%0%CW% - exit%R%
echo.
set "input="
set /p "input=  %CC%^> %R%"

if not defined input goto menu
if /i "!input!"=="0" exit
if /i "!input!"=="A" (for /L %%i in (1,1,%TOTAL%) do set "S%%i=1") & goto menu
if /i "!input!"=="C" (for /L %%i in (1,1,%TOTAL%) do set "S%%i=0") & goto menu
if /i "!input!"=="D" goto confirm

for %%n in (!input!) do (
    set "_ok=0"
    for /L %%i in (1,1,%TOTAL%) do (
        if "%%n"=="%%i" (
            set "_ok=1"
            if "!S%%i!"=="0" (set "S%%i=1") else (set "S%%i=0")
        )
    )
    if "!_ok!"=="0" echo  %CR%  Invalid: %%n%R%
)
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
echo  %CC%============================================================%R%
echo  %CC%#%CB%%CW%              Confirm Installation                     %R%%CC%#%R%
echo  %CC%============================================================%R%
echo.
echo   %CG%Will install !SC! app(s):%R%
echo.
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" echo     %CW%- !N%%i!  %CD%[!I%%i!]%R%
echo.
echo  %CC%------------------------------------------------------------%R%
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
cls
echo.
echo  %CC%============================================================%R%
echo  %CC%#%CB%%CW%              Installing apps...                       %R%%CC%#%R%
echo  %CC%============================================================%R%
echo.

set "DONE=0"
set "OK=0"
set "FAIL=0"

for /L %%i in (1,1,%TOTAL%) do (
    if "!S%%i!"=="1" (
        set /a DONE+=1
        echo  %CC%------------------------------------------------------------%R%
        echo   %CW%[!DONE!/!SC!] Installing: %CY%!N%%i!%R%
        echo   %CD%Package: !I%%i!%R%
        echo  %CC%------------------------------------------------------------%R%
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
echo  %CC%============================================================%R%
echo  %CC%#%CB%%CW%              Installation Results                     %R%%CC%#%R%
echo  %CC%============================================================%R%
echo.
for /L %%i in (1,1,%TOTAL%) do if "!S%%i!"=="1" echo     !RES%%i!
echo.
echo  %CC%------------------------------------------------------------%R%
echo   %CG%OK: !OK!%R%  ^|  %CR%Failed: !FAIL!%R%  ^|  %CW%Total: !SC!%R%
echo  %CC%------------------------------------------------------------%R%
echo.
echo  Press any key to exit...
pause >nul
exit

:: ===============================================================
::  SUBROUTINES
:: ===============================================================

:print_cat
echo   %CY%[!CAT%1!]%R%
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