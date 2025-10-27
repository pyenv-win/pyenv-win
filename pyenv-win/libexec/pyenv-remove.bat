@echo off
setlocal
chcp 65001 >nul 2>&1

if /i [%1]==[--help] goto :help
if /i [%1]==[-h] goto :help

set "MODE=KeepVersions"
set "WHATIF="

for %%A in (%*) do (
  if /i [%%~A]==[--full] set "MODE=Full"
  if /i [%%~A]==[--whatif] set "WHATIF=1"
)

set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"
if defined WHATIF (
  %PS% "& '%~dp0..\uninstall-pyenv-win.ps1' -Mode %MODE% -WhatIf"
) else (
  %PS% "& '%~dp0..\uninstall-pyenv-win.ps1' -Mode %MODE%"
)
exit /b %ERRORLEVEL%

:help
echo Usage: pyenv remove [--full] [--whatif]
echo.
echo   Removes pyenv from the current user environment.
echo   - default mode keeps installed Python versions and cache.
echo.
echo Options:
echo   --full     Remove entire ^%%USERPROFILE^%%\.pyenv\pyenv-win (versions and cache).
echo   --whatif   Simulate actions without changing anything.
echo.
echo Behavior:
echo   - Best-effort: never abort; backs up PATH/profile with timestamp under the pyenv root.
echo   - Warns about Machine PATH entries; if elevated, attempts to fix automatically.
exit /b 0

