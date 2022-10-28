@echo off
setlocal
for /f %%v in ('type "%~dp0..\..\.version"') do set "KNOWN_VER=%%v"

IF "%PYENV%" == "" (
    set version=%KNOWN_VER%
    echo PYENV variable is not set, recommended to set the variable.
    IF "%PYENV_ROOT%" == "" (
        echo PYENV_ROOT variable is not set, recommended to set the variable.
    )
    IF "%PYENV_HOME%" == "" (
        echo PYENV_HOME variable is not set, recommended to set the variable.
    )
) ELSE IF EXIST %PYENV%\..\.version (
    set version=<"%PYENV%\..\.version"
    IF "%version%" == "" set version=%KNOWN_VER%
) ELSE (
    set version=%KNOWN_VER%
)
echo pyenv %version%

:: done..!
