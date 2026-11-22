@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul 2>&1
set "PYTHONIOENCODING=utf-8"
title BloxyCola Create Server

set "PORT=8787"
set "SRV=%~dp0server.py"
set "DATA=%~dp0data.json"

rem --- Optional server password ---------------------------------
rem   StartPlaceTogetherServer.bat mypassword
rem   or set PT_SECRET in the environment before running.
rem   Every client must then enter the same password in the plugin
rem   Settings tab (SERVER PASSWORD field).
if not "%~1"=="" set "PT_SECRET=%~1"

rem --- Find Python: PATH, py launcher, portable folder --------
set "PY_CMD="

python --version >nul 2>&1
if not errorlevel 1 set "PY_CMD=python"

if not defined PY_CMD (
    py -3 --version >nul 2>&1
    if not errorlevel 1 set "PY_CMD=py -3"
)

if not defined PY_CMD if exist "%~dp0python_embed\python.exe" (
    set PY_CMD="%~dp0python_embed\python.exe"
)

if not defined PY_CMD (
    echo [ERROR] Install Python 3 and add it to PATH.
    pause
    exit /b 1
)
if not exist "%SRV%" (
    echo [ERROR] server.py must be next to this launcher.
    pause
    exit /b 1
)

rem --- Detect network IPs (errors suppressed) -----------------
set "RADMIN_IP="
set "HAMACHI_IP="
set "ZEROTIER_IP="
set "LAN_IP="

for /f "usebackq tokens=* delims=" %%a in (`powershell -NoProfile -Command "try { (Get-NetIPAddress -InterfaceAlias '*Radmin*' -AddressFamily IPv4 -ErrorAction Stop | Select-Object -First 1).IPAddress } catch { '' }" 2^>nul`) do set "RADMIN_IP=%%a"

for /f "usebackq tokens=* delims=" %%a in (`powershell -NoProfile -Command "try { (Get-NetIPAddress -InterfaceAlias '*Hamachi*' -AddressFamily IPv4 -ErrorAction Stop | Select-Object -First 1).IPAddress } catch { '' }" 2^>nul`) do set "HAMACHI_IP=%%a"

for /f "usebackq tokens=* delims=" %%a in (`powershell -NoProfile -Command "try { (Get-NetIPAddress -InterfaceAlias '*ZeroTier*' -AddressFamily IPv4 -ErrorAction Stop | Select-Object -First 1).IPAddress } catch { '' }" 2^>nul`) do set "ZEROTIER_IP=%%a"

for /f "usebackq tokens=* delims=" %%a in (`powershell -NoProfile -Command "try { (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Where-Object { $_.InterfaceAlias -match 'Ethernet|Wi-Fi|Беспроводная|Сеть' -and $_.IPAddress -notmatch '^127\.' -and $_.IPAddress -notmatch '^169\.254\.' } | Select-Object -First 1).IPAddress } catch { '' }" 2^>nul`) do set "LAN_IP=%%a"

echo.
echo   ============================================================
echo     BloxyCola Create Server
echo   ============================================================
echo.
echo   Runtime      : %PY_CMD% ^("%SRV%"^)
echo   Port         : %PORT%
echo   Data Storage : %DATA%
echo   Backups Dir  : %~dp0backups
if defined PT_SECRET (
    echo   Password     : enabled
) else (
    echo   Password     : OFF - anyone on this network can edit your place
)
echo.

if defined RADMIN_IP   echo   [Radmin VPN]  : http://%RADMIN_IP%:%PORT%
if defined HAMACHI_IP  echo   [Hamachi]     : http://%HAMACHI_IP%:%PORT%
if defined ZEROTIER_IP echo   [ZeroTier]    : http://%ZEROTIER_IP%:%PORT%
if defined LAN_IP      echo   [LAN / Wi-Fi] : http://%LAN_IP%:%PORT%
echo   [Localhost]   : http://127.0.0.1:%PORT%
echo.
echo   ------------------------------------------------------------
echo   WHAT TO PUT INTO THE ROBLOX STUDIO PLUGIN (Settings Tab):
echo   - Radmin VPN users  : copy the [Radmin VPN] address
echo   - Hamachi users     : copy the [Hamachi] address
echo   - ngrok / Porthole  : paste the public tunnel address
echo   - Same PC / Host    : http://127.0.0.1:%PORT%
echo   ------------------------------------------------------------
echo.

echo   Allow Python through Windows Firewall on your private network if prompted.
echo   Press Ctrl+C to stop the server.
echo.

%PY_CMD% "%SRV%" --port %PORT% --data "%DATA%"
set "EXITCODE=%errorlevel%"

echo.
echo   ============================================================
echo     Server stopped. Exit code: %EXITCODE%
echo   ============================================================
echo.
if not "%EXITCODE%"=="0" (
    echo   The server exited with an error.
    echo   Scroll up to read the traceback above.
    echo.
)
pause
endlocal & exit /b %EXITCODE%
