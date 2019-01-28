@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv exec ^<command^> [arg1 arg2...]
echo.
echo Runs an executable by first preparing PATH so that the selected Ruby
echo version's `bin' directory is at the front.
echo. 
echo For example, if the currently selected Ruby version is 1.9.3-p327:
echo   rbenv exec bundle install
echo. 
echo is equivalent to:
echo   PATH="$RBENV_ROOT/versions/1.9.3-p327/bin:$PATH" bundle install
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .