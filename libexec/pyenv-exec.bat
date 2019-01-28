@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv exec ^<command^> [arg1 arg2...]
echo.
echo Runs an executable by first preparing PATH so that the selected Python
echo version's `bin' directory is at the front.
echo. 
echo For example, if the currently selected Python version is 3.5.3:
echo   pyenv exec pip install -r requirements.txt
echo. 
echo is equivalent to:
echo   PATH="$PYENV_ROOT/versions/3.5.3/bin:$PATH" pip install -r requirements.txt
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file