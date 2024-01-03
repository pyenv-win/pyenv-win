@echo off
setlocal

if [%1] == [] goto :help_menu
if "%1" == "--help" goto :help_menu

set T=%TIME::=%
set TMP_FILE=pyenv_requirements_%T: =%.tmp

if not exist "%PYENV%versions\%1\" echo Python %1 does not exist & exit /b
if not exist "%PYENV%versions\%2\" echo Python %2 does not exist & exit /b

setlocal
set PIP_REQUIRE_VIRTUALENV=0
cmd /c "pyenv shell %1 & pip freeze > "%TMP%\%TMP_FILE%""
cmd /c "pyenv shell %2 & pip install -r "%TMP%\%TMP_FILE%""
cmd /c "pyenv rehash & del "%TMP%\%TMP_FILE%""
endlocal
exit /b

:help_menu
echo Usage: pyenv migrate ^<from^> ^<to^>
echo    ex. pyenv migrate 3.8.10 3.11.4
echo.
echo Migrate pip packages from a Python version to another.