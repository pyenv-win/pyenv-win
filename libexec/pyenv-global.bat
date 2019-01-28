@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv global ^<version^>
echo.
echo Sets the global Ruby version. You can override the global version at
echo any time by setting a directory-specific version with `rbenv local'
echo or by setting the `RBENV_VERSION' environment variable.
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .