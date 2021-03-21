@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv global ^<version^>
echo        pyenv global --unset
echo.
echo Sets the global Python version. You can override the global version at
echo any time by setting a directory-specific version with `pyenv local'
echo or by setting the `PYENV_VERSION' environment variable.
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file