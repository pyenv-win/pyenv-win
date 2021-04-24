@echo off
setlocal
chcp 1250 >nul

set "pyenv=cscript //nologo "%~dp0..\libexec\pyenv.vbs""

rem if 'pyenv' called alone, then run pyenv.vbs
if [%1]==[] (
  %pyenv%
  exit /b
)

rem use pyenv.vbs to aid resolving absolute path of "active" version into 'bindir'
set "bindir="
for /f %%i in ('%pyenv% version') do call :normalizepath "%~dp0..\versions\%%i" bindir

rem all help implemented as plugin
if /i [%2]==[--help] goto :plugin

rem let pyenv.vbs handle these
set commands=rehash global local version vname version-name versions commands shims which whence help --help
for %%a in (%commands%) do (
  if /i [%1]==[%%a] (
    %pyenv% %*
    exit /b
  )
)

rem jump to plugin or fall to exec
if /i not [%1]==[exec] goto :plugin


rem ====================================================================================
:exec

if not exist "%bindir%" (
  echo No global python version has been set yet. Please set the global version.
  exit /b
)

shift

for /f "tokens=1,2 delims=/" %%i in ("%1") do set "exepath=%%i" & set "exe=%%j"
if [%exe%]==[] (set "exe=%exepath%") else (set "exe=%bindir%\%exepath%\%exe%")
set "exe=cmd /c "%exe%""
goto :run




rem ====================================================================================
:plugin

set "exe=%~dp0..\libexec\pyenv-%1"
call :normalizepath %exe% exe

if exist "%exe%.bat" (
  set "exe=endlocal & call "%exe%.bat""

) else if exist "%exe.cmd%" (
  set "exe=call "%exe%.cmd""

) else if exist "%exe%.vbs" (
  set "exe=cscript //nologo "%exe%.vbs""

) else (
  echo pyenv: no such command '%1'
  exit /b
)



rem ====================================================================================
:run

rem update PATH to active version
set "path=%bindir%;%bindir%\Scripts;%path%"

rem copy params to program precisely, preserving double-quotes and percents.
rem this is the main fix for how 'exec' processing in pyenv.vbs did not
rem correctly handle (get passed) params with percent chars in them
set "params="
:paramloop
if not [%2]==[] (
  set "params=%params% %2"
  shift
  goto paramloop
)

rem run exec or plugin
%exe% %params%
exit /b




rem ====================================================================================
rem convert path which may have relative nodes (.. or .)
rem to its absolute value so can be used in PATH
:normalizepath
set "%~2=%~dpf1"
exit /b

