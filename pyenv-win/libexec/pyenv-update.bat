@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv update [--ignore]
echo.
echo Update the internal database of python installer URL's. --ignore
echo ignores any HTTP/VBScript errors that occur during downloads.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file