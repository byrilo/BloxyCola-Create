@echo off
setlocal
title Install BloxyCola Create
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0InstallStartupSound.ps1" -InstallPlugin
set "RESULT=%ERRORLEVEL%"
echo.
if not "%RESULT%"=="0" echo Installation failed. See the message above.
pause
exit /b %RESULT%
