@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv ^<command^> [^<args^>]
echo.
echo Some useful pyenv commands are:
echo    commands    List all available pyenv commands
echo    local       Set or show the local application-specific Python version
echo    global      Set or show the global Python version
echo    shell       Set or show the shell-specific Python version
echo    install     Install a Python version using python-build
echo    uninstall   Uninstall a specific Python version
echo    rehash      Rehash pyenv shims (run this after installing executables)
echo    version     Show the current Python version and its origin
echo    versions    List all Python versions available to pyenv
echo    which       Display the full path to an executable
echo    whence      List all Python versions that contain the given executable
echo.
echo See `pyenv help ^<command^>' for information on a specific command.
echo For full documentation, see: https://github.com/pyenv-win/pyenv-win#readme
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file