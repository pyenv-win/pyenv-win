@echo off

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
  if [%PYENV_VERSION%]==[] (
    echo no shell-specific version configured
  ) else (
    echo %PYENV_VERSION%
  )

) else if /i [%1]==[--unset] (
  set "PYENV_VERSION="

) else if exist "%~dp0..\versions\%1" (
  set "PYENV_VERSION=%1"

) else (
  echo pyenv specific python requisite didn't meet. Project is using different version of python.
  echo Install python '%1' by typing: 'pyenv install %1'
)
