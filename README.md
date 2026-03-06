# spotify-ads
Basically blocks all Spotify ads on desktop. Only tested on Windows — may not work on other operating systems.


## Installation 
Pretty simple — download the spotify-blocker.bat file, run it as administrator, wait for it to finish, fully close Spotify through Task Manager, and you’re good to go!


## Uninstall / Revert
It will tell you how to restore the backup if needed (or manually delete the lines starting with # === Spotify Ad Blocker from C:\Windows\System32\drivers\etc\hosts using Notepad as admin)


## Issues
It will work for most regular ads. Spotify rotates some CDN domains occasionally, so if an ad slips through after a few weeks, just run the script again (it adds the latest safe entries without duplicates).


## Line-by-line explanation of `spotify-blocker.bat`

```bat
@echo off
```
Disables the echoing of commands to the console. Without this, every command the script runs would be printed to the screen before it executes, making the output very noisy.

---

```bat
:: Check for administrator rights
net session >nul 2>&1
```
`::` marks a comment — this line is just a label for the reader. `net session` is a Windows command that succeeds only when the current user has administrator privileges. `>nul` redirects standard output to nowhere (silences it), and `2>&1` redirects standard error to the same place, so nothing is printed regardless of the outcome.

---

```bat
if %errorLevel% == 0 (
    echo Running with administrator rights...
) else (
    echo Requesting administrator rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
```
`%errorLevel%` holds the exit code of the previous command (`net session`). A value of `0` means it succeeded — i.e., the script is already running as administrator, so it simply prints a confirmation message. Otherwise, it prints a notice and uses PowerShell's `Start-Process` with `-Verb RunAs` to relaunch the same script (`%~f0` expands to the script's own full file path) with elevated privileges. `exit /b` then exits the current (non-elevated) instance so only the new elevated instance continues.

---

```bat
:: Backup current hosts file
copy "C:\Windows\System32\drivers\etc\hosts" "C:\Windows\System32\drivers\etc\hosts.backup.%date:~-4%%date:~4,2%%date:~7,2%" >nul
```
Before making any changes, the script creates a timestamped backup of the Windows hosts file. `%date:~-4%` extracts the 4-digit year, `%date:~4,2%` extracts the 2-digit month, and `%date:~7,2%` extracts the 2-digit day from the system date, resulting in a backup file named something like `hosts.backup.20260306`. `>nul` suppresses the "1 file(s) copied" message.

---

```bat
echo.
echo Disabling Spotify Ad entries...
```
`echo.` prints a blank line for readability. The second line prints a status message so the user knows what the script is doing.

---

```bat
(
echo.
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
```
The parentheses group all the `echo` statements into a single block. `>>` appends the entire block's output to the Windows hosts file instead of overwriting it. Each `echo 0.0.0.0 <domain>` line adds a hosts entry that maps the named Spotify domain to `0.0.0.0` — an unroutable address — so that any network request to that domain immediately fails. The domains covered are:

| Domain | Purpose |
|---|---|
| `adeventtracker.spotify.com` | Tracks ad-related events |
| `ads-fa.spotify.com` | Ad delivery (fast-access / CDN variant) |
| `ads-akp.spotify.com` | Ad delivery (Akamai CDN variant) |
| `ads.spotify.com` | Main ad serving endpoint |
| `audio-ak.spotify.com` | Audio ad streams (Akamai CDN) |
| `audio-akp.spotify.com` | Audio ad streams (Akamai CDN variant) |
| `analytics.spotify.com` | General analytics / telemetry |
| `analytics-fa.spotify.com` | Analytics (fast-access variant) |
| `eventtracker.spotify.com` | User-event tracking used for ad targeting |
| `heads-fa.spotify.com` | Ad banner / header assets |
| `partner.spotify.com` | Spotify's advertiser / partner platform |
| `spclient.wg.spotify.com/ad` | Spotify client API — ad endpoint |
| `spclient.wg.spotify.com/ads` | Spotify client API — ads endpoint |
| `upgrade.spotify.com` | Upgrade / upsell prompts |

The `# === Disabling ===` and `# === Finished ===` comment lines act as markers in the hosts file so users can easily find and remove the block manually if needed.

---

```bat
echo.
echo Hosts file updated successfully!
echo.
echo Close Spotify completely (check Task Manager → end all Spotify processes)
echo Then reopen Spotify. Ads should be blocked or skipped.
echo.
echo To remove this blocker later, run the same script again and choose "Remove".
pause
```
These lines print a success message and instruct the user on the next steps: close Spotify entirely via Task Manager (so the new hosts entries take effect) and reopen it. `pause` keeps the console window open so the user can read all of the output before it closes.
