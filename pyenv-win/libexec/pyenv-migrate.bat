@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv migrate ^<source-version^> ^<destination-version^>
echo.
echo Install all PIP packages from source version in destination version.
echo. 
echo For example::
echo   pyenv migrate 3.8.5 3.11.0
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file