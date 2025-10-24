@echo off
setlocal
set PS=PowerShell -NoProfile -ExecutionPolicy Bypass -Command
%PS% "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile "$env:TEMP\install-pyenv-win.ps1"; & "$env:TEMP\install-pyenv-win.ps1""
endlocal
