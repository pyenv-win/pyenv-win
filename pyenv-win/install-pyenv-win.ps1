<#
    .SYNOPSIS
    Installs pyenv-win

    .DESCRIPTION
    Installs pyenv-win to $HOME\.pyenv
    If pyenv-win is already installed, this script exits.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> install-pyenv-win.ps1
            Directory: C:\Users\joe


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    d----         2/19/2022  10:46 AM                  .pyenv
    pyenv-win is successfully installed. You may need to close and reopen your terminal before using it.

    .LINK
    Online version: https://pyenv-win.github.io/pyenv-win/
#>

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
Move-Item -Path "$PyEnvDir\pyenv-win-master\*" -Destination "$PyEnvDir"
Remove-Item -Path "$PyEnvDir\pyenv-win-master" -Recurse
Remove-Item -Path $DownloadPath

# Update env vars
$PyEnvWinDir = "${PyEnvDir}\pyenv-win"
[System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\","User")
[System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\","User")
[System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\","User")

$BinPath = "${PyEnvWinDir}\bin"
$ShimsPath = "${PyEnvWinDir}\shims"
$PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"

# Remove existing paths, so we don't add duplicates
$NewPathParts = $PathParts.Where{$_ -ne $BinPath}.Where{$_ -ne $ShimsPath}
$NewPathParts = ($BinPath, $ShimsPath) + $NewPathParts
$NewPath = $NewPathParts -Join ";"
[System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")

&"$BinPath\pyenv.ps1" rehash

&"$BinPath\pyenv.ps1" --version

If ($LastExitCode -eq 0) {
    Write-Host "pyenv-win is successfully installed. You may need to close and reopen your terminal before using it."
} Else {
    Write-Host "pyenv-win was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win/issues."
}