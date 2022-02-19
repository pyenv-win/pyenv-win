# $PyEnvDir = "${env:USERPROFILE}\.pyenv"
$PyEnvDir = "C:\Users\brand\OneDrive\Desktop\.pyenv"
$PyEnvWinDir = "${PyEnvDir}\pyenv-win"

# TODO: Check for existing folder
If (Test-Path $PyEnvWinDir) {
    Write-Host "pyenv-win already installed. Exiting."
    exit
}

$DownloadDir = "$PyEnvDir\download"
$DownloadPath = "$DownloadDir\pyenv-win.zip"

if (-not (Test-Path $DownloadDir)) {
    New-Item -Path $DownloadDir -ItemType Directory
}

Invoke-WebRequest -Uri "https://github.com/pyenv-win/pyenv-win/archive/master.zip" -OutFile "$DownloadPath" -UseBasicParsing

# TODO: Check for errors

# [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\","User")
# [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\","User")

# [System.Environment]::SetEnvironmentVariable('path', "${PyEnvWinDir}\bin;" + "${PyEnvWinDir}\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")