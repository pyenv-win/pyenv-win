<#
    .SYNOPSIS
    Installs pyenv-win

    .DESCRIPTION
    Installs pyenv-win to $HOME\.pyenv
    If pyenv-win is already installed and `-Force` is not set, this script does nothing and exits.

    .PARAMETER Force
    If set, overwrite existing pyenv-win installation

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> install-pyenv-win.ps1

    .LINK
    Online version: https://pyenv-win.github.io/pyenv-win/
#>

param (
    [switch] $Force = $False
)

$PyEnvDir = "${env:USERPROFILE}\.pyenv"

If (Test-Path $PyEnvDir) {
    Write-Host -NoNewLine "pyenv already installed. "
    If ($Force) {
        Write-Host "Overwriting."
        # TODO: Do Existing Python installations need to be preserved?
        Remove-Item -Path $PyEnvDir -Recurse
    } Else {
        Write-Host "Aborting."
        exit
    }
}

New-Item -Path $PyEnvDir -ItemType Directory

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