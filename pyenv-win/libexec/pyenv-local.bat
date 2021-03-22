@echo off
setlocal

if "%1" == "--help" (
echo Usage: pyenv local ^<version^> ^<version2^> ^<..^>
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
echo ^<version^> can be specified multiple times and should be a version
echo tag known to pyenv.  The special version string `system' will use
echo your default system Python.  Run `pyenv versions' for a list of
echo available Python versions.
echo.
echo Example: To enable the python2.7 and python3.7 shims to find their
echo          respective executables you could set both versions with:
echo.
echo 'pyenv local 3.7.0 2.7.15'
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file