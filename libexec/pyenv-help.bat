@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv ^<command^> [^<args^>]
echo.
echo Some useful rbenv commands are:
echo    commands    List all available rbenv commands
echo    local       Set or show the local application-specific Ruby version
echo    global      Set or show the global Ruby version
echo    shell       Set or show the shell-specific Ruby version
echo    install     Install a Ruby version using ruby-build
echo    uninstall   Uninstall a specific Ruby version
echo    rehash      Rehash rbenv shims (run this after installing executables)
echo    version     Show the current Ruby version and its origin
echo    versions    List all Ruby versions available to rbenv
echo    which       Display the full path to an executable
echo    whence      List all Ruby versions that contain the given executable
echo.
echo See `rbenv help ^<command^>' for information on a specific command.
echo For full documentation, see: https://github.com/rbenv/rbenv#readme
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .