@echo off
setlocal

set "src=%~1"
set "src=%src:\=_%"

IF NOT EXIST "%~dp0..\..\versions\%src%\" (
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

xcopy "%~dp0..\..\versions\%src%" "%~2" /E /H /R /K /Y /I /F
if errorlevel 1 (
  exit /b 1
)
goto :eof

:illegal
set src=
exit /b 1