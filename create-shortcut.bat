@echo off
:: Adds spotify-blocker to the Start Menu so it's launchable by name (Win key search)

set "TARGET=%~dp0spotify-blocker.bat"
set "SHORTCUT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Spotify Ad Blocker.lnk"
1
powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$s = $ws.CreateShortcut('%SHORTCUT%');" ^
  "$s.TargetPath = '%TARGET%';" ^
  "$s.WorkingDirectory = '%~dp0';" ^
  "$s.Description = 'Spotify Ad Blocker';" ^
  "$s.Save();" ^
  "$bytes = [System.IO.File]::ReadAllBytes('%SHORTCUT%');" ^
  "$bytes[0x15] = $bytes[0x15] -bor 0x20;" ^
  "[System.IO.File]::WriteAllBytes('%SHORTCUT%', $bytes);"

echo.
echo [OK] Added to Start Menu as "Spotify Ad Blocker"
echo      Press the Windows key, type "Spotify Ad", and hit Enter to run it.
echo      No desktop icons, no right-clicking.
echo.
pause
