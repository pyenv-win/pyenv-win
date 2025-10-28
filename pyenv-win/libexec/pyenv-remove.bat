@echo off
setlocal
chcp 65001 >nul 2>&1

if /i [%1]==[--help] goto :help
if /i [%1]==[-h] goto :help

set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"
%PS% "& '%~dp0..\uninstall-pyenv-win.ps1'"
exit /b %ERRORLEVEL%

:help
echo Usage: pyenv remove
echo.
echo   Removes pyenv from the current user environment.
echo   - Always prompts for confirmation and removes all (pyenv + versions).
echo   - Does not change PATH or profile automatically; prints one-liners instead.
echo.
echo Behavior:
echo   - PowerShell uninstaller removes files only; suggests up to 4 one-liners to fix PATH/profile.
exit /b 0
