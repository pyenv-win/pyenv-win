@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv which ^<command^>
echo.
echo Shows the full path of the executable
echo selected. To obtain the full path, use `pyenv which pip'.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file