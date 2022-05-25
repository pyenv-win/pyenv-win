@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv duplicate ^<available_envirment^> ^<new_enviroment^>
echo.
echo Export your enviroment.
echo. 
echo ex.^) pyenv duplicate 3.5.3 ./vendor/python
echo.
echo To use when you want to build application-specific environment.
EXIT /B
)
set "src=%~1"
set "src=%src:\=_%"

IF NOT EXIST "%~dp0..\versions\%src%\" (
echo %src% does not exist
goto :illegal
)
IF "%src%" == "" (
echo available_envirment "%src%" is illegal env name
goto :illegal
)
IF "%src%" == "." (
echo available_envirment "%src%" is illegal env name
goto :illegal
)
IF "%src%" == ".." (
echo available_envirment "%src%" is illegal env name
goto :illegal
)

xcopy "%~dp0..\versions\%src%" "%~2" /E /H /R /K /Y /I /F
if errorlevel 1 (
  exit /b 1
)
goto :eof

:illegal
set src=
exit /b 1