@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv commands
echo.
echo List all available pyenv commands
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
