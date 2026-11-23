<#
    .SYNOPSIS
    Installs pyenv-win

    .DESCRIPTION
    Installs pyenv-win to $HOME\.pyenv
    If pyenv-win is already installed, try to update to the latest version.

    .PARAMETER Uninstall
    Uninstall pyenv-win. Note that this uninstalls any Python versions that were installed with pyenv-win.

    .PARAMETER Repo
    GitHub repository to install from. Defaults to the official one.

    .PARAMETER Ref
    Branch, tag or commit SHA to install. Defaults to master.

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
    [Switch] $Uninstall = $False,
    [String] $Repo = "pyenv-win/pyenv-win",
    [String] $Ref = "master"
)

$PyEnvDir = "${env:USERPROFILE}\.pyenv"
$PyEnvWinDir = "${PyEnvDir}\pyenv-win"
$BinPath = "${PyEnvWinDir}\bin"
$ShimsPath = "${PyEnvWinDir}\shims"

Function Remove-PyEnvVars() {
    $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
    $NewPathParts = $PathParts.Where{ $_ -ne $BinPath }.Where{ $_ -ne $ShimsPath }
    $NewPath = $NewPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")

    [System.Environment]::SetEnvironmentVariable('PYENV', $null, "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', $null, "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', $null, "User")
}

Function Remove-PyEnv() {
    Write-Host "Removing $PyEnvDir..."
    If (Test-Path $PyEnvDir) {
        Remove-Item -Path $PyEnvDir -Recurse
    }
    Write-Host "Removing environment variables..."
    Remove-PyEnvVars
}

Function Get-CurrentVersion() {
    $VersionFilePath = "$PyEnvDir\.version"
    If (Test-Path $VersionFilePath) {
        $CurrentVersion = Get-Content $VersionFilePath
    }
    Else {
        $CurrentVersion = ""
    }

    Return $CurrentVersion
}

Function Get-LatestVersion() {
    $LatestVersionFilePath = "$PyEnvDir\latest.version"
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/${Repo}/${Ref}/.version", $LatestVersionFilePath)
    $LatestVersion = Get-Content $LatestVersionFilePath

    Remove-Item -Path $LatestVersionFilePath

    Return $LatestVersion
}

Function Main() {
    If ($Uninstall) {
        Remove-PyEnv
        If ($? -eq $True) {
            Write-Host "pyenv-win successfully uninstalled."
        }
        Else {
            Write-Host "Uninstallation failed."
        }
        exit
    }

    $BackupDir = "${env:Temp}/pyenv-win-backup"

    $CurrentVersion = Get-CurrentVersion
    If ($CurrentVersion) {
        Write-Host "pyenv-win $CurrentVersion installed."
        $LatestVersion = Get-LatestVersion
        If ($CurrentVersion -eq $LatestVersion) {
            Write-Host "No updates available."
            exit
        }
        Else {
            Write-Host "New version available: $LatestVersion. Updating..."

            Write-Host "Backing up existing Python installations..."
            $FoldersToBackup = "install_cache", "versions", "shims"
            ForEach ($Dir in $FoldersToBackup) {
                If (-not (Test-Path $BackupDir)) {
                    New-Item -ItemType Directory -Path $BackupDir
                }
                Move-Item -Path "${PyEnvWinDir}/${Dir}" -Destination $BackupDir
            }

            Write-Host "Removing $PyEnvDir..."
            Remove-Item -Path $PyEnvDir -Recurse
        }
    }

    New-Item -Path $PyEnvDir -ItemType Directory

    $DownloadPath = "$PyEnvDir\pyenv-win.zip"

    (New-Object System.Net.WebClient).DownloadFile("https://github.com/${Repo}/archive/${Ref}.zip", $DownloadPath)

    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile",
        "-Command `"Microsoft.PowerShell.Archive\Expand-Archive -Path \`"$DownloadPath\`" -DestinationPath \`"$PyEnvDir\`"`""
    ) -NoNewWindow -Wait

    # GitHub names the extracted folder "<repo>-<ref>", with slashes replaced by dashes.
    $RepoName = $Repo.Split("/")[-1]
    $ExtractedDir = Get-ChildItem -Path $PyEnvDir -Directory |
        Where-Object { $_.Name -like "${RepoName}-*" } | Select-Object -First 1
    If (-not $ExtractedDir) {
        Write-Host "Could not find an extracted '${RepoName}-*' folder in $PyEnvDir."
        exit 1
    }
    Move-Item -Path "$($ExtractedDir.FullName)\*" -Destination "$PyEnvDir"
    Remove-Item -Path $ExtractedDir.FullName -Recurse
    Remove-Item -Path $DownloadPath

    # Update env vars
    [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\", "User")

    $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"

    # Remove existing paths, so we don't add duplicates
    $NewPathParts = $PathParts.Where{ $_ -ne $BinPath }.Where{ $_ -ne $ShimsPath }
    $NewPathParts = ($BinPath, $ShimsPath) + $NewPathParts
    $NewPath = $NewPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")

    If (Test-Path $BackupDir) {
        Write-Host "Restoring Python installations..."
        Move-Item -Path "$BackupDir/*" -Destination $PyEnvWinDir
    }

    If ($? -eq $True) {
        Write-Host "pyenv-win is successfully installed. You may need to close and reopen your terminal before using it."
    }
    Else {
        Write-Host "pyenv-win was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win/issues."
    }
}

Main
