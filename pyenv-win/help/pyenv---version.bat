@echo off

echo Usage: pyenv --version
echo.
echo Displays the version number of this pyenv release, including the
echo current revision from git, if available.
echo.
echo The format of the git revision is:
echo   ^<major_version^>-^<train^>-^<minor_version^>
echo where `num_commits` is the number of commits since `minor_version` was
echo tagged.
echo.
EXIT /B

:: done..!
