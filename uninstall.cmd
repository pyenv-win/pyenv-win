@echo off
setlocal
set PS=powershell -NoProfile -ExecutionPolicy Bypass -Command
%PS% "& '%~dp0pyenv-win\uninstall-pyenv-win.ps1'"
exit /b %ERRORLEVEL%
