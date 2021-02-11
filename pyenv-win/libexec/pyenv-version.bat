@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv version
echo.
echo Shows the currently selected Python version and how it was selected.
echo To obtain only the version string, use `pyenv vname' or `pyenv version-name`.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file