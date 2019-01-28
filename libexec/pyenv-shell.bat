@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv shell ^<version^>
echo        rbenv shell --unset
echo.
echo Sets a shell-specific Ruby version by setting the `RBENV_VERSION'
echo environment variable in your shell. This version overrides local
echo application-specific versions and the global version.
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .