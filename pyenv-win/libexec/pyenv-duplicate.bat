@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv duplicate ^<available_envirment^> ^<new_enviroment^>
echo.
echo Duplicate your enviroment.
echo. 
echo ex.^) pyenv duplicate 3.5.3 myapp_env
echo.
echo To use when you want to create a sandbox and 
echo the environment when building application-specific environment.
EXIT /B
)
set "src=%~1"
set "dst=%~2"
set "src=%src:\=_%"
set "dst=%dst:\=_%"

IF NOT EXIST "%~dp0..\versions\%src%\" (
echo %src% is not exist
goto :illegal
)
IF EXIST "%~dp0..\versions\%dst%\" (
echo %dst% is already exist
goto :illegal
)
IF "%dst%" == "" (
echo new_enviroment "%dst%" is illegal env name
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

xcopy "%~dp0..\versions\%src%" "%~dp0..\versions\%dst%\" /E /H /R /K /Y /I /F
if errorlevel 1 (
  exit /b 1
)
goto :eof

:illegal
set src=
set dst=
exit /b 1