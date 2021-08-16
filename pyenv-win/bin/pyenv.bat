@echo off
setlocal
chcp 1250 >nul

set "pyenv=cscript //nologo "%~dp0..\libexec\pyenv.vbs""

:: if 'pyenv' called alone, then run pyenv.vbs
if [%1]==[] (
  %pyenv%
  exit /b
)

if /i [%1%2]==[version] call :check_path

:: use pyenv.vbs to aid resolving absolute path of "active" version into 'bindir'
set "bindir="
set "extrapaths="
for /f %%i in ('%pyenv% vname') do call :extrapath "%~dp0..\versions\%%i"

:: all help implemented as plugin
if /i [%2]==[--help] goto :plugin
if /i [%1]==[--help] (
  call :plugin %2 %1
  exit /b
)
if /i [%1]==[help] (
  if [%2]==[] call :plugin help --help
  if not [%2]==[] call :plugin %2 --help
  exit /b
)

:: let pyenv.vbs handle these
set commands=rehash global local version vname version-name versions commands shims which whence help --help
for %%a in (%commands%) do (
  if /i [%1]==[%%a] (
    rem endlocal not really needed here since above commands do not set any variable
    rem endlocal closed automatically with exit
    rem no need to update PATH either
    %pyenv% %*
    exit /b
  )
)

:: jump to plugin or fall to exec
if /i not [%1]==[exec] goto :plugin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:exec

if not exist "%bindir%" (
  echo No global python version has been set yet. Please set the global version by typing:
  echo pyenv global 3.7.2
  exit /b
)

set cmdline=%*
set cmdline=%cmdline:~5%
:: update PATH to active version and run command
:: endlocal needed only if cmdline sets a variable: SET FOO=BAR
set cmddir=
if exist %bindir%\%2 set cmddir=%bindir%\
if exist %bindir%\%2.exe set cmddir=%bindir%\
if exist %bindir%\%2.bat set cmddir=%bindir%\
set "path=%extrapaths%%path%"
%cmddir%%cmdline%
endlocal
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:plugin
set "exe=%~dp0..\libexec\pyenv-%1"
rem TODO needed?
call :normalizepath %exe% exe

if exist "%exe%.bat" (
  set "exe=call "%exe%.bat""

) else if exist "%exe.cmd%" (
  set "exe=call "%exe%.cmd""

) else if exist "%exe%.vbs" (
  set "exe=cscript //nologo "%exe%.vbs""

) else (
  echo pyenv: no such command '%1'
  exit /b 1
)

:: replace first arg with %exe%
set cmdline=%*
set cmdline=%cmdline:^=^^%
set cmdline=%cmdline:!=^!%
set arg1=%1
set len=1
:loop_len
set /a len=%len%+1
set "arg1=%arg1:~1%"
if not [%arg1%]==[] goto :loop_len

setlocal enabledelayedexpansion
set "cmdline=!exe! !cmdline:~%len%!"
:: run command (no need to update PATH for plugins)
:: endlocal needed to ensure exit will not automatically close setlocal
:: otherwise PYTHON_VERSION will be lost
endlocal && endlocal && %cmdline%
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
call :normalizepath %python_shim% python_shim
set "python_where="
for /f "delims=" %%f in ('where python') do call :set_python_where %%f
:: On recent Windows versions, where finds python shim with shebang first
if /i [%python_shim%]==[%python_where%.bat] goto :eof
if /i [%python_shim%]==[%python_where%] goto :eof
call :bad_path "%python_where%"
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: set python_where variable if empty
:set_python_where
if [%python_where%]==[] set "python_where=%~1"
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: tell bad PATH and exit
:bad_path
set bad_python=%~1
set bad_dir=%~dp1
echo [91mFATAL: Found [95m%bad_python%[91m version before pyenv in PATH.[0m
echo [91mPlease remove [95m%bad_dir%[91m from PATH for pyenv to work properly.[0m
goto :eof