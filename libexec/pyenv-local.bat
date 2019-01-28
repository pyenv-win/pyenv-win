@echo off
setlocal

if "%1" == "--help" (
echo Usage: rbenv local ^<version^>
echo        rbenv local --unset
echo.
echo Sets the local application-specific Ruby version by writing the
echo version name to a file named `.ruby-version'.
echo.
echo When you run a Ruby command, rbenv will look for a `.ruby-version'
echo file in the current directory and each parent directory. If no such
echo file is found in the tree, rbenv will use the global Ruby version
echo specified with `rbenv global'. A version specified with the
echo `RBENV_VERSION' environment variable takes precedence over local
echo and global versions.
echo.
EXIT /B
)

rem Implementation of this command is in the rbenv.vbs file .