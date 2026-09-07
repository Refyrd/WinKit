@echo off
chcp 65001 >nul

:: ═══════════════════════════════════════════════════════════════
::  AutoInstall — быстрая установка программ через WinGet
::  GitHub: https://github.com/Refyrd/AutoInstall
:: ═══════════════════════════════════════════════════════════════

:: Проверка прав администратора
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
title AutoInstall — Мастер установки ПО

:: ─── Цвета ───
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_RESET=%ESC%[0m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_RED=%ESC%[91m"
set "C_GRAY=%ESC%[90m"
set "C_WHITE=%ESC%[97m"
set "C_BOLD=%ESC%[1m"

:: ─── Список приложений ───
:: Формат: NAME_N=Отображаемое имя | ID_N=WinGet ID
set "TOTAL=9"

set "NAME_1=Google Chrome"
set "ID_1=Google.Chrome"
set "CAT_1=Браузеры"

set "NAME_2=Mozilla Firefox"
set "ID_2=Mozilla.Firefox"
set "CAT_2=Браузеры"

set "NAME_3=Visual Studio Code"
set "ID_3=Microsoft.VisualStudioCode"
set "CAT_3=Разработка"

set "NAME_4=Steam"
set "ID_4=Valve.Steam"
set "CAT_4=Игры и общение"

set "NAME_5=Discord"
set "ID_5=Discord.Discord"
set "CAT_5=Игры и общение"

set "NAME_6=VLC Media Player"
set "ID_6=VideoLAN.VLC"
set "CAT_6=Медиа и утилиты"

set "NAME_7=7-Zip"
set "ID_7=7zip.7zip"
set "CAT_7=Медиа и утилиты"

set "NAME_8=Happ"
set "ID_8=Happ.Happ"
set "CAT_8=Медиа и утилиты"

set "NAME_9=MSI Afterburner"
set "ID_9=Guru3D.Afterburner"
set "CAT_9=Медиа и утилиты"

:: ─── Инициализация выбора ───
for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=0"

:: ═══════════════════════════════════════════════════════════════
::  ГЛАВНОЕ МЕНЮ
:: ═══════════════════════════════════════════════════════════════
:main_menu
cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%          AutoInstall — Мастер установки ПО            %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

:: Вывод списка по категориям
set "LAST_CAT="
for /L %%i in (1,1,%TOTAL%) do (
    if not "!CAT_%%i!"=="!LAST_CAT!" (
        echo   %C_YELLOW%[!CAT_%%i!]%C_RESET%
        set "LAST_CAT=!CAT_%%i!"
    )
    if "!SEL_%%i!"=="1" (
        echo     %C_GREEN%  %%i. [■] !NAME_%%i!%C_RESET%
    ) else (
        echo       %%i. [ ] !NAME_%%i!
    )
)

:: Подсчёт выбранных
set "SEL_COUNT=0"
for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" set /a SEL_COUNT+=1
)

echo.
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo   %C_WHITE%Выбрано: %C_GREEN%!SEL_COUNT!%C_WHITE% из %TOTAL%%C_RESET%
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo.
echo   %C_WHITE%Введите номера через пробел %C_GRAY%(например: 1 3 5 7)%C_RESET%
echo   %C_GREEN%A%C_WHITE% — выбрать все  %C_YELLOW%C%C_WHITE% — сбросить выбор%C_RESET%
echo   %C_GREEN%D%C_WHITE% — начать установку  %C_RED%0%C_WHITE% — выход%C_RESET%
echo.
set "input="
set /p "input=  %C_CYAN%^> %C_RESET%"

:: Пустой ввод
if not defined input goto main_menu

:: Выход
if /i "%input%"=="0" (
    echo.
    echo  %C_GRAY%Выход...%C_RESET%
    timeout /t 1 >nul
    exit
)

:: Выбрать все
if /i "%input%"=="A" (
    for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=1"
    goto main_menu
)

:: Сбросить выбор
if /i "%input%"=="C" (
    for /L %%i in (1,1,%TOTAL%) do set "SEL_%%i=0"
    goto main_menu
)

:: Начать установку
if /i "%input%"=="D" goto confirm_phase

:: Обработка номеров (переключение)
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
        echo  %C_RED%  Неверный номер: %%n%C_RESET%
        timeout /t 1 >nul
    )
)
goto main_menu

:: ═══════════════════════════════════════════════════════════════
::  ПОДТВЕРЖДЕНИЕ
:: ═══════════════════════════════════════════════════════════════
:confirm_phase

:: Подсчёт выбранных
set "SEL_COUNT=0"
for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" set /a SEL_COUNT+=1
)

if !SEL_COUNT! equ 0 (
    echo.
    echo  %C_RED%Вы не выбрали ни одной программы!%C_RESET%
    timeout /t 2 >nul
    goto main_menu
)

cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%              Подтверждение установки                  %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.
echo   %C_GREEN%Будут установлены (!SEL_COUNT! шт.)::%C_RESET%
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
echo   %C_WHITE%1. Начать установку%C_RESET%
echo   %C_WHITE%2. Вернуться к выбору%C_RESET%
echo   %C_WHITE%3. Отмена и выход%C_RESET%
echo.
set "input="
set /p "input=  %C_CYAN%^> %C_RESET%"

if "%input%"=="1" goto install_phase
if "%input%"=="2" goto main_menu
if "%input%"=="3" (
    echo.
    echo  %C_GRAY%Установка отменена. Выход...%C_RESET%
    timeout /t 2 >nul
    exit
)

echo  %C_RED%  Неверный ввод. Повторите.%C_RESET%
goto ask_confirm

:: ═══════════════════════════════════════════════════════════════
::  УСТАНОВКА
:: ═══════════════════════════════════════════════════════════════
:install_phase
cls
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%               Установка программ...                  %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

set "DONE=0"
set "OK=0"
set "FAIL=0"

for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" (
        set /a DONE+=1
        echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
        echo   %C_WHITE%[!DONE!/!SEL_COUNT!] Установка: %C_YELLOW%!NAME_%%i!%C_RESET%
        echo   %C_GRAY%Пакет: !ID_%%i!%C_RESET%
        echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
        echo.

        winget install --id !ID_%%i! -e --source winget --accept-package-agreements --accept-source-agreements

        if !errorlevel! equ 0 (
            set /a OK+=1
            set "RES_%%i=%C_GREEN%✓ Успешно%C_RESET%"
            echo.
            echo   %C_GREEN%✓ !NAME_%%i! — установлено успешно%C_RESET%
        ) else (
            set /a FAIL+=1
            set "RES_%%i=%C_RED%✗ Ошибка%C_RESET%"
            echo.
            echo   %C_RED%✗ !NAME_%%i! — ошибка установки%C_RESET%
        )
        echo.
    )
)

:: ═══════════════════════════════════════════════════════════════
::  ИТОГИ
:: ═══════════════════════════════════════════════════════════════
echo.
echo  %C_CYAN%╔════════════════════════════════════════════════════════╗%C_RESET%
echo  %C_CYAN%║%C_BOLD%%C_WHITE%                 Результаты установки                  %C_RESET%%C_CYAN%║%C_RESET%
echo  %C_CYAN%╚════════════════════════════════════════════════════════╝%C_RESET%
echo.

for /L %%i in (1,1,%TOTAL%) do (
    if "!SEL_%%i!"=="1" (
        echo     !RES_%%i!  —  !NAME_%%i!
    )
)

echo.
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo   %C_GREEN%Успешно: !OK!%C_RESET%  │  %C_RED%Ошибки: !FAIL!%C_RESET%  │  %C_WHITE%Всего: !SEL_COUNT!%C_RESET%
echo  %C_CYAN%────────────────────────────────────────────────────────%C_RESET%
echo.
echo  Нажмите любую клавишу для выхода...
pause >nul
exit