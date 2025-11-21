@echo off
title 5Ware
setlocal enabledelayedexpansion

:: Check for admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "FIVEM_PATH=%LocalAppData%\FiveM\FiveM.app\mods"
set "SELECTED_MODS="
set "FAILED_MODS="

:menu
cls
color 0F
echo.
echo                                       [+]=====================================[+]
echo                                       [+]                5Ware                [+]
echo                                       [+]          Beta Internal Kit          [+]
echo                                       [+]              Ver: 0.0.1             [+]
echo                                       [+]-------------------------------------[+]
echo                                       [+] Note: You cannot mix the following  [+]
echo                                       [+]  items below with the Fast Reload   [+]
echo                                       [+]     It will break Fast Reload.      [+]
echo                                       [+]-------------------------------------[+]
echo                                       [+]  [+] No Fall  [+] Infinite Stamina  [+]
echo                                       [+]=====================================[+]
echo.
echo.
echo           [+] 1. One Shot (Weapon - AC Detected)               [+] 2. No Recoil (Weapon - Undetected)
echo           [+] 3. Soft Aimbot (Weapon - Semi Undetected)        [+] 4. Hard Aimbot (Weapon - Semi Undetected)
echo           [+] 5. Fast Reload (Player - Undetected)             [+] 6. Magic Bullets (Weapon - Semi Undetected)
echo           [+] 7. No Fall Damage (Player - Undetected)          [+] 8. Quick Reactions (Movement - Undetected)
echo           [+] 9. Infinite Stamina (Player - Undetected)        [+] 10. 5Ware (Join The Discord Server)
echo           [+] 11. Load Selected Mods                           [+] 12. Exit
echo.

if defined SELECTED_MODS echo Currently selected: !SELECTED_MODS!
echo.
set /p choice=Enter a number choice: 

if "%choice%"=="1" call :select_mod 1 & goto menu
if "%choice%"=="2" call :select_mod 2 & goto menu
if "%choice%"=="3" call :select_mod 3 & goto menu
if "%choice%"=="4" call :select_mod 4 & goto menu
if "%choice%"=="5" call :select_mod 5 & goto menu
if "%choice%"=="6" call :select_mod 6 & goto menu
if "%choice%"=="7" call :select_mod 7 & goto menu
if "%choice%"=="8" call :select_mod 8 & goto menu
if "%choice%"=="9" call :select_mod 9 & goto menu
if "%choice%"=="10" start https://discord.gg/aVT27gryay & goto menu
if "%choice%"=="11" call :load_mods & goto menu
if "%choice%"=="12" exit /b
goto menu

:: -----------------------------
:: Add mod to selection
:: -----------------------------
:select_mod
echo !SELECTED_MODS! | find " %~1" >nul || set "SELECTED_MODS=!SELECTED_MODS! %~1,"
echo Option %~1 Selected.
timeout /t 1 >nul
exit /b

:: -----------------------------
:: Load all selected mods
:: -----------------------------
:load_mods
cls
set "ERROR_INFO_SHOWN="
if not defined SELECTED_MODS (
    ...
)

if not exist "%FIVEM_PATH%" (
    mkdir "%FIVEM_PATH%"
    :: Hide folder and mark as system
    attrib +h +s "%FIVEM_PATH%"

    :: Take ownership to current user and set full permissions
    takeown /f "%FIVEM_PATH%" /r /d y >nul 2>&1
    icacls "%FIVEM_PATH%" /grant "%USERNAME%:(OI)(CI)F" /t >nul 2>&1

    :: Encrypt folder (NTFS encryption)
    cipher /e "%FIVEM_PATH%" >nul 2>&1

    echo.
    echo Created Path..
) else (
    echo.
    echo Path already exists..
)

:: Wait for FiveM to start (max 1 minute, exits script if timeout)
:wait_for_fivem_start
set /a WAIT_SECONDS=0

tasklist /fi "imagename eq FiveM.exe" | find /i "FiveM.exe" >nul
set "FIVEM1=%errorlevel%"
tasklist /fi "imagename eq FiveMApp.exe" | find /i "FiveMApp.exe" >nul
set "FIVEM2=%errorlevel%"

if %FIVEM1% neq 0 if %FIVEM2% neq 0 (
    echo.
    echo Waiting for FiveM to start...
    :wait_fivem_loop
    tasklist /fi "imagename eq FiveM.exe" | find /i "FiveM.exe" >nul
    set "FIVEM1=%errorlevel%"
    tasklist /fi "imagename eq FiveMApp.exe" | find /i "FiveMApp.exe" >nul
    set "FIVEM2=%errorlevel%"

    if %FIVEM1% neq 0 if %FIVEM2% neq 0 (
        set /a WAIT_SECONDS+=5
        if %WAIT_SECONDS% GEQ 60 (
            cls
            echo.
            echo [INFO] FiveM did not start within 1 minute.
            echo.
            echo [INFO] Returning to Main Menu...
            timeout /t 2 >nul
            goto menu
        )
        timeout /t 5 >nul
        goto wait_fivem_loop
    )
)

cls

:: Inject all selected mods
for %%M in (!SELECTED_MODS!) do call :process_mod %%M

:: Show summary of all failed mods if any
if defined FAILED_MODS (
    cls
    echo.
    powershell -Command "Write-Host '5Ware [INFO] - The Following Failed to Load:' -ForegroundColor White"
    echo.

    call :print_failed FAILED_MODS

    echo.

    if not defined ERROR_INFO_SHOWN (
        echo.
        powershell -Command "Write-Host '5Ware [INFO] - 1. If You Are Receiving This Message That Means You Hit a Roadblock Make a Ticket..' -ForegroundColor White"
        echo.
        powershell -Command "Write-Host '5Ware [INFO] - 2. Once you have made a Ticket in the 5Ware Discord Send Us the ERROR Code..' -ForegroundColor White"
        echo.
        powershell -Command "Write-Host '5Ware [INFO] - 3. Joining the Discord is Required to get Support..' -ForegroundColor White"
        echo.
        echo.
        powershell -Command "Write-Host '5Ware [ERROR] - [Code: xX9b7K1S2]' -ForegroundColor Red"
        echo.
        start https://discord.gg/uyeQ3GBXg7
        set "ERROR_INFO_SHOWN=1"
        echo.
        echo Press any key to continue...
        pause >nul
        cls
    )
)

:: Wait for FiveM to close
echo.
echo Waiting for FiveM to close...
:wait_for_fivem_close
tasklist /fi "imagename eq FiveM.exe" | find /i "FiveM.exe" >nul
set "FIVEM1=%errorlevel%"
tasklist /fi "imagename eq FiveMApp.exe" | find /i "FiveMApp.exe" >nul
set "FIVEM2=%errorlevel%"
if %FIVEM1%==0 (
    timeout /t 4 >nul
    goto wait_for_fivem_close
)
if %FIVEM2%==0 (
    timeout /t 4 >nul
    goto wait_for_fivem_close
)

cls

echo.
powershell -Command "Write-Host '5Ware [INFO] - FiveM has closed...' -ForegroundColor Red"
timeout /t 2 >nul
echo.

:: Cleanup all injected files + folder
for %%M in (!SELECTED_MODS!) do call :cleanup_mod %%M
if exist "%FIVEM_PATH%" (
    cls
    :: Mods folder deleted
    powershell -Command "Write-Host '5Ware [INFO] - 1. Remnants Are, Suppressing..' -ForegroundColor White"
    echo.
    timeout /t 1 >nul
    rmdir /s /q "%FIVEM_PATH%".
    powershell -Command "Write-Host '5Ware [INFO] - 2. Remnants Safely, Suppressed..' -ForegroundColor Green"
    echo.
    powershell -Command "Write-Host '5Ware [INFO] - 3. Suppression Safely, Completed..' -ForegroundColor White"
    echo.
    powershell -Command "Write-Host '5Ware [INFO] - 4. Traces Were Safely, Removed..' -ForegroundColor Red"
    echo.
    powershell -Command "Write-Host '5Ware [INFO] - 5. Will Now Continue Back to Main Menu' -ForegroundColor White"
    echo.
    timeout /t 2 >nul
)

set "SELECTED_MODS="
timeout /t 2 >nul
exit /b

:: -----------------------------
:: Mod definitions
:: -----------------------------
:process_mod
set "MOD=%~1"
if "%MOD%"=="1" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/streamedpeds_players.rpf"
    set "FILE=%FIVEM_PATH%\streamedpeds_players.rpf"
    set "NAME=One Shot"
)
if "%MOD%"=="2" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/pedprops.rpf"
    set "FILE=%FIVEM_PATH%\pedprops.rpf"
    set "NAME=No Recoil"
)
if "%MOD%"=="3" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/grassparticlesfx.rpf"
    set "FILE=%FIVEM_PATH%\grassparticlesfx.rpf"
    set "NAME=Soft Aimbot"
)
if "%MOD%"=="4" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/grassparticlesfxx.rpf"
    set "FILE=%FIVEM_PATH%\grassparticlesfxx.rpf"
    set "NAME=Hard Aimbot"
)
if "%MOD%"=="5" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/SCRIPT.rpf"
    set "FILE=%FIVEM_PATH%\SCRIPT.rpf"
    set "NAME=Fast Reload"
)
if "%MOD%"=="6" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/common.rpf"
    set "FILE=%FIVEM_PATH%\common.rpf"
    set "NAME=Magic Bullet"
)
if "%MOD%"=="7" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/Player.rpf"
    set "FILE=%FIVEM_PATH%\Player.rpf"
    set "NAME=No Fall Damage"
)
if "%MOD%"=="8" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/RADIO_X.rpf"
    set "FILE=%FIVEM_PATH%\RADIO_X.rpf"
    set "NAME=Quick Reactions"
)
if "%MOD%"=="9" (
    set "URL=https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/update.rpf"
    set "FILE=%FIVEM_PATH%\update.rpf"
    set "NAME=Infinite Stamina"
)


echo.
set "PS_CMD=try {Invoke-WebRequest -Uri '%URL%' -OutFile '%FILE%' -ErrorAction Stop; Write-Host 'Running: %NAME%..'} catch {Write-Host ('' + ''); exit 1}"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "!PS_CMD!"
echo.

if exist "%FILE%" (
    ::%NAME% - %FILE%
    powershell -Command "Write-Host '%NAME%: Is Running..' -ForegroundColor White"
) else (
    :: Collect failed mod names
    if defined FAILED_MODS (
    set "FAILED_MODS=!FAILED_MODS!|%NAME%"
    ) else (
    set "FAILED_MODS=%NAME%"
)
)
echo.
exit /b

:: -----------------------------
:: Cleanup subroutine
:: -----------------------------
:cleanup_mod
set "MOD=%~1"
if "%MOD%"=="1" del "%FIVEM_PATH%\grassparticlesfx.rpf" >nul 2>&1
if "%MOD%"=="2" del "%FIVEM_PATH%\streamedpeds_players.rpf" >nul 2>&1
if "%MOD%"=="3" del "%FIVEM_PATH%\pedprops.rpf" >nul 2>&1
if "%MOD%"=="4" del "%FIVEM_PATH%\grassparticlesfxx.rpf" >nul 2>&1
if "%MOD%"=="5" del "%FIVEM_PATH%\common.rpf" >nul 2>&1
if "%MOD%"=="6" del "%FIVEM_PATH%\update.rpf" >nul 2>&1
if "%MOD%"=="7" del "%FIVEM_PATH%\Player.rpf" >nul 2>&1
if "%MOD%"=="8" del "%FIVEM_PATH%\RADIO_X.rpf" >nul 2>&1
if "%MOD%"=="9" del "%FIVEM_PATH%\SCRIPT.rpf" >nul 2>&1
exit /b


:print_failed
:: %1 = variable name containing pipe-delimited failed mods
setlocal enabledelayedexpansion
set "VAR=!%1!"
:print_failed_loop
if "!VAR!"=="" goto :eof
for /f "tokens=1* delims=|" %%A in ("!VAR!") do (
    powershell -Command "Write-Host '5Ware [ERROR] - %%A' -ForegroundColor Red"
    set "VAR=%%B"
    goto print_failed_loop
)
endlocal
exit /b