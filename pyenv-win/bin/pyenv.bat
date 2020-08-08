@echo off
setlocal
chcp 65001 >nul

set "pyenv=cscript //nologo "%~dp0"..\libexec\pyenv.vbs"

rem if not the 'exec' command then just call pyenv.vbs directly and exit
if /i not [%1]==[exec] (
  %pyenv% %*
  exit /b
)

if /i [%2]==[--help] (
  echo Usage: pyenv exec ^<command^> [arg1 arg2...]
  echo.
  echo Runs an executable by first preparing PATH so that the selected Python
  echo version's `bin' directory is at the front.
  echo.
  echo For example, if the currently selected Python version is 3.5.3:
  echo   pyenv exec pip install -r requirements.txt
  echo.
  echo is equivalent to:
  echo   PATH="$PYENV_ROOT/versions/3.5.3/bin:$PATH" pip install -r requirements.txt
  echo.
  exit /b
)

rem handle 'exec' command.
rem 'exec' is enhanced such that now any program can be launched using it.
rem it ensures that PATH is prefixed so 'current' version of python will
rem be used by the program passed to 'exec', should it use python itself

rem use pyenv.vbs to aid resolving absolute path (as 'bindir') to 'current' version
rem and then prepend it to PATH
for /f %%i in ('%pyenv% version') do call :normalizepath "%~dp0..\versions\%%i" bindir
set "path=%bindir%;%bindir%\Scripts;%path%"

rem pyenv's shim for 'pip' (pip.bat) calls "pyenv exec Scripts/pip"
rem but its shim for 'python' calls 'pyenv exec python'.
rem in the first case we need to deal with the '/' being used,
rem and that because of 'Scripts', we must launch with absolute path
rem whereas in the later case we can launch with only the program name (python)
rem relying on PATH to result in Windows correctly locating it (which
rem is how we can now launch any program using 'pyenv exec')

for /f "tokens=1,2 delims=/" %%i in ("%2") do set "exepath=%%i" & set "exe=%%j"
if [%exe%]==[] (set "exe=%exepath%") else (set "exe=%bindir%\%exepath%\%exe%")

rem 'exe' will be either like "C:\<pyenvhome>\versions\<version>\Scripts\pip"
rem or simply like "python" (or 'dir' when 'pyenv exec dir' called, for ex)

rem copy params to program precisely, preserving double-quotes and percents.
rem this is the main fix for how 'exec' processing in pyenv.vbs did not
rem correctly handle (get passed) params with percent chars in them
:loop
if not [%3]==[] (
  set params=%params% %3
  shift
  goto loop
)

rem 'exe' could be a '.bat' file (or any ext in pathext), in which case
rem it must be launched using 'cmd' to ensure '~dpn' is correct when used
rem within the '.bat' file. also, calling here fixes concurrency problem
rem created by the 'exec.bat' approach pyenv.vbs uses
cmd /c %exe% %params%
exit /b

rem ----
rem convert path which may have relative nodes (.. or .)
rem to its absolute value so can be used in PATH
:normalizepath
set "%~2=%~dpf1"
exit /b
