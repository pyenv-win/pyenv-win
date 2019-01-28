@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv versions [--bare] [--skip-aliases]
echo.
echo Lists all Ruby versions found in `$RBENV_ROOT/versions/*'.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .