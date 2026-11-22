@echo off
setlocal
title Install BloxyCola Create
set "PLUGIN=%~dp0PlaceTogether.rbxmx"
set "PLUGIN_DIR=%LOCALAPPDATA%\Roblox\Plugins"
if not exist "%PLUGIN%" (
    echo Extract the entire ZIP before running the installer.
    goto :failed
)
if not exist "%PLUGIN_DIR%" (
    mkdir "%PLUGIN_DIR%" || goto :failed
)
copy /y "%PLUGIN%" "%PLUGIN_DIR%\PlaceTogether.rbxmx" >nul || goto :failed
echo BloxyCola Create is installed. Open Roblox Studio, or restart it if it is already open.
pause
exit /b 0

:failed
echo Installation failed. See the message above.
pause
exit /b 1
