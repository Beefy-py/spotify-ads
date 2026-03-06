@echo off

:: Check for administrator rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator rights...
) else (
    echo Requesting administrator rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =============================================
echo   Spotify Ad Blocker
echo =============================================
echo.
echo  [1] Add    - Block Spotify ads
echo  [2] Remove - Restore Spotify ads
echo  [3] Exit
echo.
set /p "choice=Enter your choice (1/2/3): "

if "%choice%"=="1" goto ADD
if "%choice%"=="2" goto REMOVE
if "%choice%"=="3" goto END

echo Invalid choice. Exiting.
goto END

:ADD
:: Check if entries are already present to avoid duplicates
findstr /c:"# === Disabling ===" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% == 0 (
    echo.
    echo Spotify ad blocker entries already exist in the hosts file.
    echo Nothing to do.
    goto END
)

call :BACKUP
echo.
echo Disabling Spotify Ad entries...

(
echo # === Disabling ===
echo 0.0.0.0 adeventtracker.spotify.com
echo 0.0.0.0 ads-fa.spotify.com
echo 0.0.0.0 ads-akp.spotify.com
echo 0.0.0.0 ads.spotify.com
echo 0.0.0.0 audio-ak.spotify.com
echo 0.0.0.0 audio-akp.spotify.com
echo 0.0.0.0 analytics.spotify.com
echo 0.0.0.0 analytics-fa.spotify.com
echo 0.0.0.0 eventtracker.spotify.com
echo 0.0.0.0 heads-fa.spotify.com
echo 0.0.0.0 partner.spotify.com
echo 0.0.0.0 spclient.wg.spotify.com/ad
echo 0.0.0.0 spclient.wg.spotify.com/ads
echo 0.0.0.0 upgrade.spotify.com
echo # === Finished ===
) >> "C:\Windows\System32\drivers\etc\hosts"

echo.
echo Hosts file updated successfully!
echo.
echo Close Spotify completely (check Task Manager - end all Spotify processes)
echo Then reopen Spotify. Ads should be blocked or skipped.
goto END

:REMOVE
:: Check if entries exist before attempting removal
findstr /c:"# === Disabling ===" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo No Spotify ad blocker entries found in the hosts file.
    echo Nothing to remove.
    goto END
)

call :BACKUP
echo.
echo Removing Spotify Ad blocker entries...

:: Use PowerShell to remove all lines between and including the markers
powershell -Command ^
    "$hosts = 'C:\Windows\System32\drivers\etc\hosts';" ^
    "$lines = Get-Content $hosts;" ^
    "$result = @();" ^
    "$skip = $false;" ^
    "foreach ($line in $lines) {" ^
    "    if ($line -match [regex]::Escape('# === Disabling ===')) { $skip = $true }" ^
    "    elseif ($line -match [regex]::Escape('# === Finished ===')) { $skip = $false }" ^
    "    elseif (-not $skip) { $result += $line }" ^
    "};" ^
    "($result | Out-String).TrimEnd() | Set-Content $hosts"

echo.
echo Spotify ad blocker entries removed from the hosts file.
echo.
echo Close Spotify completely (check Task Manager - end all Spotify processes)
echo Then reopen Spotify. Ads will no longer be blocked.
goto END

:BACKUP
copy "C:\Windows\System32\drivers\etc\hosts" "C:\Windows\System32\drivers\etc\hosts.backup.%date:~-4%%date:~4,2%%date:~7,2%" >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Failed to create a backup of the hosts file. Proceeding anyway.
)
exit /b

:END
echo.
pause
