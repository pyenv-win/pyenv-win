# TODO: Add description

$PyEnvDir = "${env:USERPROFILE}\.pyenv"

# TODO: Add Force parameter
If (Test-Path $PyEnvDir) {
    Write-Host "pyenv-win already installed. Exiting."
    exit
} Else {
    New-Item -Path $PyEnvDir -ItemType Directory
}

$DownloadPath = "$PyEnvDir\pyenv-win.zip"

Invoke-WebRequest -Uri "https://github.com/pyenv-win/pyenv-win/archive/master.zip" -OutFile "$DownloadPath" -UseBasicParsing
Expand-Archive -Path $DownloadPath -DestinationPath $PyEnvDir
Move-Item -Path "$PyEnvDir\pyenv-win-master\pyenv-win" -Destination "$PyEnvDir"
Remove-Item -Path "$PyEnvDir\pyenv-win-master" -Recurse
Remove-Item -Path $DownloadPath

# TODO: Check for errors

$PyEnvWinDir = "${PyEnvDir}\pyenv-win"
# [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\","User")

# [System.Environment]::SetEnvironmentVariable('path', "${PyEnvWinDir}\bin;" + "${PyEnvWinDir}\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")

# TODO: pyenv rehash

# TODO: pyenv --version

Write-Host "pyenv-win is successfully installed. You may need to close and reopen your terminal before using it."