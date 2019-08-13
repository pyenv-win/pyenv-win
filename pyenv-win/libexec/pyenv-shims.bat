@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv shims
echo        pyenv shims --short
echo.
echo List the existing pyenv shims
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
