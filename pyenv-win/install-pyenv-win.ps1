<#
    .SYNOPSIS
    Installs pyenv-win

    .DESCRIPTION
    Installs pyenv-win to $HOME\.pyenv
    If pyenv-win is already installed, try to update to the latest version.

    .PARAMETER Uninstall
    Uninstall pyenv-win. Note that this uninstalls any Python versions that were installed with pyenv-win.

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
    [Switch] $Uninstall = $False
)
    
$PyEnvDir = Join-Path ([System.IO.Path]::GetFullPath($env:USERPROFILE)) ".pyenv"
$PyEnvWinDir = Join-Path  ${PyEnvDir} "pyenv-win"
$BinPath = Join-Path  ${PyEnvWinDir} "bin"
$ShimsPath = Join-Path  ${PyEnvWinDir} "shims"
$LibsPath = Join-Path  ${PyEnvWinDir} "libexec\libs"
    
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
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/.version", $LatestVersionFilePath)
    $LatestVersion = Get-Content $LatestVersionFilePath

    Remove-Item -Path $LatestVersionFilePath

    Return $LatestVersion
}

Function GenerateShim() {
    Write-Host "Generating shim executable..."

    # Python version to generate shim.exe with pyinstaller
    $PythonArch = "win32"
    $PythonVersion = "3.12.3"
    $PythonVer = $PythonVersion.Split(".")[0..1] -join ""
    $TempFolder = Join-Path ([System.IO.Path]::GetFullPath($env:Temp)) $(New-Guid)

    Push-Location
    New-Item -Type Directory -Path $TempFolder | Out-Null
    Set-Location $TempFolder
    Invoke-WebRequest "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-$PythonArch.zip" -OutFile python.zip
    Expand-Archive -Path python.zip -DestinationPath python
    (Get-Content "python\python$PythonVer._pth") -replace "#import site", "import site" | Set-Content "python\python$PythonVer._pth"
    Invoke-WebRequest https://bootstrap.pypa.io/get-pip.py -OutFile python\get-pip.py
    try
    {
        $ReqVenv = $env:PIP_REQUIRE_VIRTUALENV
        $env:PIP_REQUIRE_VIRTUALENV = "0"
        & .\python\python python\get-pip.py
        & .\python\Scripts\pip install pyinstaller
        & .\python\Scripts\pyinstaller "$LibsPath\shim.py" --onedir --contents-directory shim --debug noarchive --noupx
    } finally {
        $env:PIP_REQUIRE_VIRTUALENV = $ReqVenv
    }
    Pop-Location

    Get-ChildItem -Path "$TempFolder\dist\shim\*" | Copy-Item -Destination $LibsPath -Recurse -Container -Force
    Remove-Item $TempFolder -Recurse
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

    (New-Object System.Net.WebClient).DownloadFile("https://github.com/pyenv-win/pyenv-win/archive/master.zip", $DownloadPath)

    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile",
        "-Command `"Microsoft.PowerShell.Archive\Expand-Archive -Path \`"$DownloadPath\`" -DestinationPath \`"$PyEnvDir\`"`""
    ) -NoNewWindow -Wait

    Move-Item -Path "$PyEnvDir\pyenv-win-master\*" -Destination "$PyEnvDir"
    Remove-Item -Path "$PyEnvDir\pyenv-win-master" -Recurse
    Remove-Item -Path $DownloadPath

    # Generate shim executable
    GenerateShim

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
