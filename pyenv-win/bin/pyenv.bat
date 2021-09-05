@echo off
setlocal
chcp 1250 >nul

set "__pyenv_pyenv=cscript //nologo "%~dp0..\libexec\pyenv.vbs""

:: if 'pyenv' called alone, then run pyenv.vbs
if [%1]==[] (
  %__pyenv_pyenv%
  exit /b
)

if /i [%1%2]==[version] call :check_path

:: use pyenv.vbs to aid resolving absolute path of "active" version into '__pyenv_bindir'
set "__pyenv_bindir="
set "__pyenv_extrapaths="
for /f %%i in ('%__pyenv_pyenv% vname') do call :extrapath "%~dp0..\versions\%%i"

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
set "__pyenv_commands=rehash global local version vname version-name versions commands shims which whence help --help"
for %%a in (%__pyenv_commands%) do (
  if /i [%1]==[%%a] (
    rem endlocal not really needed here since above commands do not set any variable
    rem endlocal closed automatically with exit
    rem no need to update PATH either
    %__pyenv_pyenv% %*
    exit /b
  )
)

:: jump to plugin or fall to exec
if /i not [%1]==[exec] goto :plugin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:exec

if not exist "%__pyenv_bindir%" (
  echo No global python version has been set yet. Please set the global version by typing:
  echo pyenv global 3.7.2
  exit /b
)

set "__pyenv_cmdline=%*"
set "__pyenv_cmdline=%__pyenv_cmdline:~5%"
:: update PATH to active version and run command
:: endlocal needed only if cmdline sets a variable: SET FOO=BAR
call :remove_shims_from_path
%__pyenv_cmdline%
endlocal
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:remove_shims_from_path
:: arcane magic courtesy of StackOverflow question 5471556

set "__pyenv_path=%path%"
set "__pyenv_path=%__pyenv_path:"=""%"
set "__pyenv_path=%__pyenv_path:^=^^%"
set "__pyenv_path=%__pyenv_path:&=^&%"
set "__pyenv_path=%__pyenv_path:|=^|%"
set "__pyenv_path=%__pyenv_path:<=^<%"
set "__pyenv_path=%__pyenv_path:>=^>%"

set "__pyenv_path=%__pyenv_path:;=^;^;%"
rem ** This is the key line, the missing quote is intended
set __pyenv_path=%__pyenv_path:""="%
set "__pyenv_path=%__pyenv_path:"=""%"

set "__pyenv_path=%__pyenv_path:;;="";""%"
set "__pyenv_path=%__pyenv_path:^;^;=;%"
set "__pyenv_path=%__pyenv_path:""="%"
set "__pyenv_path=%__pyenv_path:"=""%"
set "__pyenv_path=%__pyenv_path:"";""=";"%"
set "__pyenv_path=%__pyenv_path:"""="%"

set "__pyenv_python_shims=%~dp0..\shims"
call :normalizepath "%__pyenv_python_shims%" __pyenv_python_shims
set "path=%__pyenv_extrapaths%"

setlocal EnableDelayedExpansion
for %%a in ("!__pyenv_path!") do (
    endlocal
    if /i not "%%~a"=="%__pyenv_python_shims%" call :append_to_path %%~a
    setlocal EnableDelayedExpansion
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:append_to_path
set "path=%path%%*;"
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:plugin
set "__pyenv_exe=%~dp0..\libexec\pyenv-%1"
rem TODO needed?
call :normalizepath %__pyenv_exe% __pyenv_exe

if exist "%__pyenv_exe%.bat" (
  set "__pyenv_exe=call "%__pyenv_exe%.bat""

) else if exist "%__pyenv_exe%.cmd" (
  set "__pyenv_exe=call "%__pyenv_exe%.cmd""

) else if exist "%__pyenv_exe%.vbs" (
  set "__pyenv_exe=cscript //nologo "%__pyenv_exe%.vbs""

) else (
  echo pyenv: no such command '%1'
  exit /b 1
)

:: replace first arg with %__pyenv_exe%
set "__pyenv_cmdline=%*"
set "__pyenv_cmdline=%__pyenv_cmdline:^=^^%"
set "__pyenv_cmdline=%__pyenv_cmdline:!=^!%"
set "__pyenv_arg1=%1"
set "__pyenv_len=1"
:loop_len
set /a __pyenv_len=%__pyenv_len%+1
set "__pyenv_arg1=%__pyenv_arg1:~1%"
if not [%__pyenv_arg1%]==[] goto :loop_len

setlocal enabledelayedexpansion
set "__pyenv_cmdline=!__pyenv_exe! !__pyenv_cmdline:~%__pyenv_len%!"
:: run command (no need to update PATH for plugins)
:: endlocal needed to ensure exit will not automatically close setlocal
:: otherwise PYTHON_VERSION will be lost
endlocal && endlocal && %__pyenv_cmdline%
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
call :normalizepath %1 __pyenv_bindir
set "__pyenv_extrapaths=%__pyenv_extrapaths%%__pyenv_bindir%;%__pyenv_bindir%\Scripts;"
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check pyenv python shim is first in PATH
:check_path
set "__pyenv_python_shim=%~dp0..\shims\python.bat"
if not exist "%__pyenv_python_shim%" goto :eof
call :normalizepath "%__pyenv_python_shim%" __pyenv_python_shim
set "__pyenv_python_where="
for /f "delims=" %%f in ('where python') do call :set_python_where "%%f"
:: On recent Windows versions, where finds python shim with shebang first
if /i "%__pyenv_python_shim%"=="%__pyenv_python_where:~1,-1%.bat" goto :eof
if /i "%__pyenv_python_shim%"=="%__pyenv_python_where:~1,-1%" goto :eof
call :bad_path %__pyenv_python_where%
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: set __pyenv_python_where variable if empty
:set_python_where
if [%__pyenv_python_where%]==[] set "__pyenv_python_where="%~1""
goto :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: tell bad PATH and exit
:bad_path
set "__pyenv_bad_python=%~1"
set "__pyenv_bad_dir=%~dp1"
echo [91mFATAL: Found [95m%__pyenv_bad_python%[91m version before pyenv in PATH.[0m
echo [91mPlease remove [95m%__pyenv_bad_dir%[91m from PATH for pyenv to work properly.[0m
goto :eof