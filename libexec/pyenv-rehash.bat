@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv rehash
echo.
echo Rehash rbenv shims ^(run this after installing executables^)
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .