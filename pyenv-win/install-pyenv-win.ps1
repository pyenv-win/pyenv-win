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
    $url = 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/.version'
    $retries = 5
    for($i=1;$i -le $retries;$i++){
        try {
            Invoke-WebRequest -UseBasicParsing -Headers @{ 'User-Agent'='Mozilla/5.0' } -Uri $url -OutFile $LatestVersionFilePath -ErrorAction Stop
            break
        } catch {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
                $ra = $_.Exception.Response.GetResponseHeader('Retry-After')
                $s = 0
                if ([int]::TryParse($ra,[ref]$s)) { Start-Sleep -Seconds $s } else { Start-Sleep -Seconds ([int][math]::Pow(2,$i)) }
            } else {
                throw
            }
        }
    }
    $LatestVersion = if (Test-Path $LatestVersionFilePath) { Get-Content $LatestVersionFilePath } else { '' }
    if (Test-Path $LatestVersionFilePath) { Remove-Item -Path $LatestVersionFilePath -Force }
    return $LatestVersion
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
    $zipUrl = 'https://github.com/mauriciomenon/pyenv-win_adaptado/archive/master.zip'
    $retries = 5
    for($i=1;$i -le $retries;$i++){
        try {
            Invoke-WebRequest -UseBasicParsing -Headers @{ 'User-Agent'='Mozilla/5.0' } -Uri $zipUrl -OutFile $DownloadPath -ErrorAction Stop
            break
        } catch {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
                $ra = $_.Exception.Response.GetResponseHeader('Retry-After')
                $s = 0
                if ([int]::TryParse($ra,[ref]$s)) { Start-Sleep -Seconds $s } else { Start-Sleep -Seconds ([int][math]::Pow(2,$i)) }
            } else {
                throw
            }
        }
    }

    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile",
        "-Command `"Microsoft.PowerShell.Archive\Expand-Archive -Path \`"$DownloadPath\`" -DestinationPath \`"$PyEnvDir\`"`""
    ) -NoNewWindow -Wait

    Move-Item -Path "$PyEnvDir\pyenv-win_adaptado-master\*" -Destination "$PyEnvDir"
    Remove-Item -Path "$PyEnvDir\pyenv-win_adaptado-master" -Recurse
    Remove-Item -Path $DownloadPath

    # Ensure required folders exist
    New-Item -ItemType Directory -Path (Join-Path $PyEnvWinDir 'install_cache') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $PyEnvWinDir 'shims') -Force | Out-Null

    # Update env vars
    [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvWinDir}\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvWinDir}\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvWinDir}\", "User")
    $env:PYENV = "${PyEnvWinDir}\"
    $env:PYENV_ROOT = "${PyEnvWinDir}\"
    $env:PYENV_HOME = "${PyEnvWinDir}\"

    $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"

    # Remove existing pyenv-win paths from other locations (including scoop) and duplicates
    $NewPathParts = @()
    foreach($p in $PathParts){
        if([string]::IsNullOrWhiteSpace($p)){ continue }
        $pp = $p.Trim()
        $isOurBin   = ($pp -ieq $BinPath)
        $isOurShims = ($pp -ieq $ShimsPath)
        $isOtherPyenvBin   = ($pp -match '\\pyenv-win\\bin$'   -and -not $isOurBin)
        $isOtherPyenvShims = ($pp -match '\\pyenv-win\\shims$' -and -not $isOurShims)
        if($isOtherPyenvBin -or $isOtherPyenvShims){ continue }
        if($pp -ne $BinPath -and $pp -ne $ShimsPath){ $NewPathParts += $pp }
    }
    $NewPathParts = ($BinPath, $ShimsPath) + $NewPathParts
    $NewPath = $NewPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")

    # Persist in PowerShell profile: add init block if missing
    try {
        $profileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
        if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
        $init = @"
# pyenv-win (init)





"@
        $init = @"
# pyenv-win (init)





"@
        $init = @"
# pyenv-win (init)





"@
        $init = @"
# pyenv-win (init)

$env:PYENV_ROOT = '$PyEnvWinDir'
if (Test-Path "$env:PYENV_ROOT\bin" -and (Test-Path "$env:PYENV_ROOT\shims")) {
  if ($env:PATH -notmatch [regex]::Escape("$env:PYENV_ROOT\bin")) {
    $env:PATH = "$env:PYENV_ROOT\bin;$env:PYENV_ROOT\shims;" + $env:PATH
  }
}
"@
        $current = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue | Out-String
        if ($null -eq $current -or ($current -notmatch '# pyenv-win \(init\)')) {
            Add-Content -Path $PROFILE -Value "`r`n$init" -Encoding UTF8
        }
    } catch {
        Write-Host "Warning: failed to update PowerShell profile: $($_.Exception.Message)"
    }

    If (Test-Path $BackupDir) {
        Write-Host "Restoring Python installations..."
        try {
            Get-ChildItem -LiteralPath $BackupDir -Force | ForEach-Object {
                $target = Join-Path $PyEnvWinDir $_.Name
                if (Test-Path $target) {
                    Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force -ErrorAction SilentlyContinue
                } else {
                    Move-Item -LiteralPath $_.FullName -Destination $PyEnvWinDir -Force -ErrorAction SilentlyContinue
                }
            }
            Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Warning: failed to fully restore backup: $($_.Exception.Message)"
        }
    }
    
    # No automatic update of versions cache. Use 'pyenv update' when needed.

    If ($? -eq $True) {
        Write-Host "pyenv-win installed. Changes applied:"
        Write-Host "  - User env vars: PYENV, PYENV_ROOT, PYENV_HOME"
        Write-Host "  - User PATH updated: $BinPath;$ShimsPath preprended"
        Write-Host "  - PowerShell profile updated: $PROFILE (pyenv-win init block)"
        Write-Host "Reloading profile for this session..."
        try { . $PROFILE } catch { }
        Write-Host "Quick check:"
        try { & "$PyEnvWinDir\bin\pyenv.bat" --version } catch {}
        Write-Host "Done. Open a new terminal for all apps to pick up PATH."
    }
    Else {
        Write-Host "pyenv-win was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win/issues."
    }
}

Main
