@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv vname
echo.
echo Shows the currently selected Python version.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file