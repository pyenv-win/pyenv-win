@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv rehash
echo.
echo Rehash pyenv shims ^(run this after installing executables^)
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file