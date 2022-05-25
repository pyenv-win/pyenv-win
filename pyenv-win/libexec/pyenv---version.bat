@echo off
setlocal
for /f %%v in ('type "%~dp0..\..\.version"') do set "KNOWN_VER=%%v"

if "%1" == "--help" (
echo Usage: pyenv --version
echo.
echo Displays the version number of this pyenv release, including the
echo current revision from git, if available.
echo.
echo The format of the git revision is:
echo   ^<major_version^>-^<train^>-^<minor_version^>
echo where `num_commits` is the number of commits since `minor_version` was
echo tagged.
echo.
EXIT /B
)

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
