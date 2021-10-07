@echo off
setlocal

set "skip=-1"
for /f "delims=" %%i in ('echo skip') do (call :incrementskip)
if [%skip%]==[0] set "skip_arg="
if not [%skip%]==[0] set "skip_arg=skip=%skip% "

if "%1" == "--help" (
  echo Usage: pyenv shell ^<version^>
  echo        pyenv shell --unset
  echo.
  echo Sets a shell-specific Python version by setting the `PYENV_VERSION'
  echo environment variable in your shell. This version overrides local
  echo application-specific versions and the global version.
  echo.
  EXIT /B
)

if [%1]==[] (
  if "%PYENV_VERSION%"=="" (
    echo no shell-specific version configured
  ) else (
    echo %PYENV_VERSION%
  )

) else if /i [%1]==[--unset] (
  endlocal && set "PYENV_VERSION="

) else (
  cscript //nologo "%~dp0pyenv.vbs" shell %* 1> nul || goto :error
  for /f "%skip_arg%delims=" %%a in ('cscript //nologo "%~dp0pyenv.vbs" shell %*') do (
    endlocal && set "PYENV_VERSION=%%a"
  )
)

goto :eof

:incrementskip
set /a skip=%skip%+1
goto :eof

:error
cscript //nologo "%~dp0pyenv.vbs" shell %*
exit /b %errorlevel%

