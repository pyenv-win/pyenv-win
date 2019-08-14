@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv whence [--path] ^<command^>
echo.
echo Shows the currently given executable contains path
echo selected. To obtain python version of executable, use `pyenv whence pip'.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file