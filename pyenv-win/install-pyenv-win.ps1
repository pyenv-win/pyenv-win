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
$VersionFilePath = "${PyEnvDir}\.version"
$PayloadVersionPath = Join-Path $PyEnvWinDir '.version'
    
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
        # Only update when we have a non-empty latest and it differs
        If ($LatestVersion -and ($CurrentVersion -ne $LatestVersion)) {
            Write-Host "New version available: $LatestVersion. Updating..."
            
            Write-Host "Backing up existing Python installations..."
            $FoldersToBackup = "install_cache", "versions", "shims"
            ForEach ($Dir in $FoldersToBackup) {
                If (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
                $src = Join-Path $PyEnvWinDir $Dir
                if (Test-Path $src) { Move-Item -LiteralPath $src -Destination $BackupDir -Force -ErrorAction SilentlyContinue }
            }
            
            Write-Host "Removing $PyEnvDir..."
            Remove-Item -Path $PyEnvDir -Recurse
        } else {
            Write-Host "No updates available."
            exit
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

    # Move only the pyenv-win payload into %USERPROFILE%\.pyenv\pyenv-win to avoid clutter
    if (-not (Test-Path $PyEnvWinDir)) { New-Item -ItemType Directory -Path $PyEnvWinDir -Force | Out-Null }
    if (Test-Path "$PyEnvDir\pyenv-win_adaptado-master\pyenv-win") {
        Copy-Item -Recurse -Force "$PyEnvDir\pyenv-win_adaptado-master\pyenv-win\*" $PyEnvWinDir
    } else {
        # Fallback: if layout changes, copy only when pyenv-win exists at root
        if (Test-Path "$PyEnvDir\pyenv-win") { Copy-Item -Recurse -Force "$PyEnvDir\pyenv-win\*" $PyEnvWinDir }
    }

    # Write version once into payload and point top-level .version to it via symlink when possible (or copy as fallback) to keep a single source of truth
    $SourceVersionPath = Join-Path $PyEnvDir 'pyenv-win_adaptado-master\.version'
    if (Test-Path $SourceVersionPath) {
        Copy-Item -LiteralPath $SourceVersionPath -Destination $PayloadVersionPath -Force
    } elseif ((Get-Variable -Name 'LatestVersion' -ErrorAction SilentlyContinue) -and $LatestVersion) {
        Set-Content -Path $PayloadVersionPath -Value $LatestVersion -Encoding ASCII
    } elseif (-not (Test-Path $PayloadVersionPath)) {
        Set-Content -Path $PayloadVersionPath -Value "unknown" -Encoding ASCII
    }

    if (Test-Path $VersionFilePath) {
        Remove-Item -LiteralPath $VersionFilePath -Force
    }
    try {
        if (Test-Path $PayloadVersionPath) {
            New-Item -ItemType SymbolicLink -Path $VersionFilePath -Target $PayloadVersionPath -Force | Out-Null
        } else {
            throw "Target version file does not exist"
        }
    } catch {
        # If symlink is not allowed, fall back to copy
        Copy-Item -LiteralPath $PayloadVersionPath -Destination $VersionFilePath -Force
    }

    # Cleanup extracted tree and zip
    if (Test-Path "$PyEnvDir\pyenv-win_adaptado-master") { Remove-Item -Path "$PyEnvDir\pyenv-win_adaptado-master" -Recurse -Force }
    if (Test-Path "$PyEnvDir\pyenv-win") { Remove-Item -Path "$PyEnvDir\pyenv-win" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path $DownloadPath) { Remove-Item -Path $DownloadPath -Force }

    # Ensure required folders exist
    New-Item -ItemType Directory -Path (Join-Path $PyEnvWinDir 'install_cache') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $PyEnvWinDir 'shims') -Force | Out-Null

    # Update env vars
    [System.Environment]::SetEnvironmentVariable('PYENV', "$PyEnvWinDir", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "$PyEnvWinDir", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "$PyEnvWinDir", "User")
    $env:PYENV = "$PyEnvWinDir"
    $env:PYENV_ROOT = "$PyEnvWinDir"
    $env:PYENV_HOME = "$PyEnvWinDir"

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
        $init = @'
# pyenv-win (init)
$env:PYENV_ROOT = "$HOME\.pyenv\pyenv-win"
if (Test-Path "$env:PYENV_ROOT\bin" -and (Test-Path "$env:PYENV_ROOT\shims")) {
  if ($env:PATH -notmatch [regex]::Escape("$env:PYENV_ROOT\bin")) {
    $env:PATH = "$env:PYENV_ROOT\bin;$env:PYENV_ROOT\shims;" + $env:PATH
  }
}
'@
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
        # Optional: offer immediate Python install
        try {
            Write-Host ""; Write-Host "Optional: install Python now?" -ForegroundColor Cyan
            $raw = & cscript //nologo "$PyEnvWinDir\libexec\pyenv-install.vbs" --list 2>$null
            $versText = @()
            foreach($line in $raw){
              $m = [regex]::Match($line, '^\s*(3\.\d+\.\d+)\s*$')
              if ($m.Success) { $versText += $m.Groups[1].Value }
            }
            $vers = $versText | ForEach-Object { [version]$_ }
            if ($vers.Count -gt 0) {
              $latest = ($vers | Sort-Object -Descending | Select-Object -First 1)
              function pickLatestMinor([int]$minor){ ($vers | Where-Object { $_.Major -eq 3 -and $_.Minor -eq $minor } | Sort-Object -Descending | Select-Object -First 1) }
              $v310 = pickLatestMinor 10; $v311 = pickLatestMinor 11; $v312 = pickLatestMinor 12; $v313 = pickLatestMinor 13
              $menu = @(); if ($latest) { $menu += "1) Latest stable: $($latest.ToString())" }
              if ($v310) { $menu += "2) 3.10 latest:   $($v310.ToString())" }
              if ($v311) { $menu += "3) 3.11 latest:   $($v311.ToString())" }
              if ($v312) { $menu += "4) 3.12 latest:   $($v312.ToString())" }
              if ($v313) { $menu += "5) 3.13 latest:   $($v313.ToString())" }
              $menu += "M) Manual (skip)"
              $menu | ForEach-Object { Write-Host "  $_" }
              $choice = Read-Host "Choose [1/2/3/4/5/M] (default: M)"
              if ([string]::IsNullOrWhiteSpace($choice)) { $choice = 'M' }
              $choice = ($choice.Substring(0,1)).ToUpper()
              $target = $null
              switch ($choice) { '1' { $target = $latest }; '2' { $target = $v310 }; '3' { $target = $v311 }; '4' { $target = $v312 }; '5' { $target = $v313 }; default { $target = $null } }
              if ($target) {
                $tv = $target.ToString()
                Write-Host "Installing Python $tv ..." -ForegroundColor Yellow
                & "$PyEnvWinDir\bin\pyenv.bat" install -s $tv
                & "$PyEnvWinDir\bin\pyenv.bat" global $tv
                & "$PyEnvWinDir\bin\pyenv.bat" rehash
                try { python --version } catch {}
                Write-Host "Installed and set global: $tv" -ForegroundColor Green
              } else {
                Write-Host "Skipping auto-install. You can run:" -ForegroundColor Yellow
                Write-Host "  pyenv install <version>" -ForegroundColor DarkGray
                Write-Host "  pyenv global <version>   # set default" -ForegroundColor DarkGray
                Write-Host "  pyenv local  <version>   # per-folder" -ForegroundColor DarkGray
              }
            }
        } catch { Write-Host "Note: could not offer auto-install ($($_.Exception.Message))." -ForegroundColor Yellow }
        Write-Host "Done. Open a new terminal for all apps to pick up PATH."
    }
    Else {
        Write-Host "pyenv-win was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win/issues."
    }
}

Main
