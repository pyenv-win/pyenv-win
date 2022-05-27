@echo off
setlocal
chcp 1250 >nul

set "pyenv=cscript //nologo "%~dp0..\libexec\pyenv.vbs""

:: if 'pyenv' called alone, then run pyenv.vbs
if [%1]==[] (
  %pyenv% || goto :error
  exit /b
)

set "skip=-1"
for /f "delims=" %%i in ('echo skip') do (call :incrementskip)
if [%skip%]==[0] set "skip_arg="
if not [%skip%]==[0] set "skip_arg=skip=%skip% "

if /i [%1%2]==[version] call :check_path

:: use pyenv.vbs to aid resolving absolute path of "active" version into 'bindir'
set "bindir="
set "extrapaths="
for /f "%skip_arg%delims=" %%i in ('%pyenv% vname') do call :extrapath "%~dp0..\versions\%%i"

:: Add %AppData% Python Scripts to %extrapaths%.
for /F "tokens=1,2 delims=-" %%i in ('%pyenv% vname') do (
  if /i "%%j" == "win32" (
    for /F "tokens=1,2,3 delims=." %%a in ("%%i") do (
        set "extrapaths=%extrapaths%%AppData%\Python\Python%%a%%b-32\Scripts;"
    )
  ) else (
     for /F "tokens=1,2,3 delims=." %%a in ("%%i") do (
        set "extrapaths=%extrapaths%%AppData%\Python\Python%%a%%b\Scripts;"
    )
  )
)

:: all help implemented as plugin
if /i [%2]==[--help] goto :plugin
if /i [%1]==[--help] (
  call :plugin %2 %1 || goto :error
  exit /b
)
if /i [%1]==[help] (
  if [%2]==[] call :plugin help --help || goto :error
  if not [%2]==[] call :plugin %2 --help || goto :error
  exit /b
)

:: let pyenv.vbs handle these
set "commands=rehash global local version vname version-name versions commands shims which whence help --help"
for %%a in (%commands%) do (
  if /i [%1]==[%%a] (
    rem endlocal not really needed here since above commands do not set any variable
    rem endlocal closed automatically with exit
    rem no need to update PATH either
    %pyenv% %* || goto :error
    exit /b
  )
)

:: jump to plugin or fall to exec
if /i not [%1]==[exec] goto :plugin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:exec

if not exist "%bindir%" (
  echo No global/local python version has been set yet. Please set the global/local version by typing:
  echo pyenv global 3.7.4
  echo pyenv local 3.7.4
  exit /b
)

set "cmdline=%*"
set "cmdline=%cmdline:~5%"

:: update PATH to active version and run command
:: endlocal needed only if cmdline sets a variable: SET FOO=BAR
call :remove_shims_from_path
%cmdline% ||  goto :error

endlocal
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:remove_shims_from_path
set "python_shims=%~dp0..\shims"
call :normalizepath "%python_shims%" python_shims
set "_path=%path%"
set "path=%extrapaths%"

:: arcane magic courtesy of StackOverflow question 5471556
:: https://stackoverflow.com/a/7940444/381865
setlocal DisableDelayedExpansion
:: escape all special characters
set "_path=%_path:"=""%"
set "_path=%_path:^=^^%"
set "_path=%_path:&=^&%"
set "_path=%_path:|=^|%"
set "_path=%_path:<=^<%"
set "_path=%_path:>=^>%"
set "_path=%_path:;=^;^;%"
:: the 'missing' quotes below are intended
set _path=%_path:""="%
:: " => ""Q (like quote)
set "_path=%_path:"=""Q%"
:: ;; => "S"S (like semicolon)
set "_path=%_path:;;="S"S%"
set "_path=%_path:^;^;=;%"
set "_path=%_path:""="%"
setlocal EnableDelayedExpansion

:: "Q => <empty>
set "_path=!_path:"Q=!"
:: "S"S => ";"
for %%a in ("!_path:"S"S=";"!") do (
  if "!!"=="" (
    endlocal
    endlocal
  )
  if %%a neq "" (
    if /i not "%%~dpfa"=="%python_shims%" call :append_to_path %%~dpfa
  )
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:append_to_path
set "path=%path%%*;"
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:plugin
set "exe=%~dp0..\libexec\pyenv-%1"
rem TODO needed?
call :normalizepath %exe% exe

if exist "%exe%.bat" (
  set "exe=call "%exe%.bat""

) else if exist "%exe%.cmd" (
  set "exe=call "%exe%.cmd""

) else if exist "%exe%.vbs" (
  set "exe=cscript //nologo "%exe%.vbs""

) else (
  echo pyenv: no such command '%1'
  exit /b 1
)

:: replace first arg with %exe%
set "cmdline=%*"
set "cmdline=%cmdline:^=^^%"
set "cmdline=%cmdline:!=^!%"
set "arg1=%1"
set "len=1"
:loop_len
set /a len=%len%+1
set "arg1=%arg1:~1%"
if not [%arg1%]==[] goto :loop_len

setlocal enabledelayedexpansion
set "cmdline=!exe! !cmdline:~%len%!"
:: run command (no need to update PATH for plugins)
:: endlocal needed to ensure exit will not automatically close setlocal
:: otherwise PYTHON_VERSION will be lost
endlocal && endlocal && %cmdline% || goto :error
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: convert path which may have relative nodes (.. or .)
:: to its absolute value so can be used in PATH
:normalizepath
set "%~2=%~dpf1"
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: compute list of paths to add for all activated python versions
:extrapath
call :normalizepath %1 bindir
set "extrapaths=%extrapaths%%bindir%;%bindir%\Scripts;"
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check pyenv python shim is first in PATH
:check_path
set "python_shim=%~dp0..\shims\python.bat"
if not exist "%python_shim%" goto :eof
call :normalizepath "%python_shim%" python_shim
set "python_where="
for /f "%skip_arg%delims=" %%a in ('where python') do (
  if /i "%python_shim%"=="%%~dpfa" goto :eof
  call :set_python_where %%~dpfa
)
call :bad_path "%python_where%"
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: set python_where variable if empty
:set_python_where
if "%python_where%"=="" set "python_where=%*"
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: tell bad PATH and exit
:bad_path
set "bad_python=%~1"
set "bad_dir=%~dp1"
echo [91mFATAL: Found [95m%bad_python%[91m version before pyenv in PATH.[0m
echo [91mPlease remove [95m%bad_dir%[91m from PATH for pyenv to work properly.[0m
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: if AutoExec/AutoRun is configured for cmd it probably ends with the `cls` command
:: meaning there will be a Form Feed (U+000C) included in the output.
:: so we add it as a dilimiter so that we can skip x number of lines.
:: we find out how many to skip and pass that tot the skip option of the for loop,
:: EXCEPT skip=0 gives errors...
:: so we prepend every command with `echo skip` to force skip being at least 1
:incrementskip
set /a skip=%skip%+1
goto :eof

:error
exit /b %errorlevel%
