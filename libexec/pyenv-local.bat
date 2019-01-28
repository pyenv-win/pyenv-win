@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv local ^<version^>
echo        pyenv local --unset
echo.
echo Sets the local application-specific Python version by writing the
echo version name to a file named `.python-version'.
echo.
echo When you run a Python command, pyenv will look for a `.python-version'
echo file in the current directory and each parent directory. If no such
echo file is found in the tree, pyenv will use the global Python version
echo specified with `pyenv global'. A version specified with the
echo `PYENV_VERSION' environment variable takes precedence over local
echo and global versions.
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file