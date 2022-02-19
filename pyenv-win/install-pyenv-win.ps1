$PyEnvDir = "${env:USERPROFILE}\.pyenv"

# TODO: Check for existing folder
If (Test-Path $PyEnvDir) {
    Write-Host "pyenv-win already installed. Exiting."
    exit
} Else {
    New-Item -Path $PyEnvDir -ItemType Directory
}

$DownloadPath = "$PyEnvDir\pyenv-win.zip"

Invoke-WebRequest -Uri "https://github.com/pyenv-win/pyenv-win/archive/master.zip" -OutFile "$DownloadPath" -UseBasicParsing
Expand-Archive -Path $DownloadPath -DestinationPath $PyEnvDir

Remove-Item -Path $DownloadPath

# TODO: Check for errors

$PyEnvWinDir = "${PyEnvDir}\pyenv-win"
# [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\","User")

# [System.Environment]::SetEnvironmentVariable('path', "${PyEnvWinDir}\bin;" + "${PyEnvWinDir}\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")