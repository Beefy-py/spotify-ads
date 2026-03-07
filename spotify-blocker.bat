@echo off
setlocal EnableDelayedExpansion

:: Check for administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "HOSTS=C:\Windows\System32\drivers\etc\hosts"
set "MARKER_START=# === Spotify Ad Block Start ==="
set "MARKER_END=# === Spotify Ad Block End ==="

echo.
echo ==========================================
echo   Spotify Ad Blocker
echo ==========================================
echo.
echo  [1] Block Spotify Ads
echo  [2] Remove Ad Block Entries
echo  [3] Exit
echo.
set /p choice="Choose an option: "

if "%choice%"=="1" goto :block
if "%choice%"=="2" goto :remove
if "%choice%"=="3" exit /b
echo Invalid choice.
goto :eof

:: -----------------------------------------------
:block
:: Check if already applied
findstr /c:"%MARKER_START%" "%HOSTS%" >nul 2>&1
if %errorLevel% == 0 (
    echo.
    echo [!] Spotify ad block entries already exist.
    echo     Remove them first ^(option 2^) before re-applying.
    echo.
    pause
    exit /b
)

:: Backup hosts file (use wmic for locale-independent datetime)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DT=%%I"
set "BACKUP=%HOSTS%.backup.%DT:~0,8%_%DT:~8,6%"
copy "%HOSTS%" "%BACKUP%" >nul
echo [+] Backup saved to: %BACKUP%

echo.
echo [+] Adding Spotify ad block entries...

(
echo.
echo %MARKER_START%
echo 0.0.0.0 adeventtracker.spotify.com
echo 0.0.0.0 adservice.spotify.com
echo 0.0.0.0 ads.spotify.com
echo 0.0.0.0 ads-fa.spotify.com
echo 0.0.0.0 ads-akp.spotify.com
echo 0.0.0.0 analytics.spotify.com
echo 0.0.0.0 analytics-fa.spotify.com
echo 0.0.0.0 eventtracker.spotify.com
echo 0.0.0.0 heads-fa.spotify.com
echo 0.0.0.0 partner.spotify.com
echo 0.0.0.0 upgrade.spotify.com
echo 0.0.0.0 gads.spotify.com
echo 0.0.0.0 log.spotify.com
echo 0.0.0.0 marketing.spotify.com
echo 0.0.0.0 adclick.g.doubleclick.net
echo 0.0.0.0 pagead2.googlesyndication.com
echo 0.0.0.0 pubads.g.doubleclick.net
echo %MARKER_END%
) >> "%HOSTS%"

echo [+] Flushing DNS cache...
ipconfig /flushdns >nul

echo.
echo [OK] Done! Spotify ads should now be blocked.
echo.
echo     - Fully close Spotify ^(check Task Manager for lingering processes^)
echo     - Reopen Spotify
echo.
pause
exit /b

:: -----------------------------------------------
:remove
findstr /c:"%MARKER_START%" "%HOSTS%" >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [!] No Spotify ad block entries found in hosts file.
    echo.
    pause
    exit /b
)

echo.
echo [+] Removing Spotify ad block entries...

:: Write hosts file content excluding the block between markers
set "SKIP=0"
set "TMPFILE=%TEMP%\hosts_tmp_%RANDOM%.txt"

> "%TMPFILE%" (
    for /f "usebackq delims=" %%L in ("%HOSTS%") do (
        set "LINE=%%L"
        if "!LINE!"=="%MARKER_START%" (
            set "SKIP=1"
        )
        if "!SKIP!"=="0" (
            echo(%%L
        )
        if "!LINE!"=="%MARKER_END%" (
            set "SKIP=0"
        )
    )
)

copy /y "%TMPFILE%" "%HOSTS%" >nul
del "%TMPFILE%"

echo [+] Flushing DNS cache...
ipconfig /flushdns >nul

echo.
echo [OK] Spotify ad block entries removed.
echo.
pause
exit /b
