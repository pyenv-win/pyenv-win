@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv versions [--bare] [--skip-aliases]
echo.
echo Lists all Python versions found in `$PYENV_ROOT/versions/*'.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file