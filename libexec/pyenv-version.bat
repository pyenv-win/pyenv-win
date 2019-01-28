@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv version
echo.
echo Shows the currently selected Ruby version and how it was
echo selected. To obtain only the version string, use `rbenv
echo version-name'.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .