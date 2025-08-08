@echo off
REM PowerShell-based pyenv update command for Windows 11 compatibility
REM This replaces the VBScript version that has issues with Windows 11

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

REM Parse arguments
set "PS_ARGS="
set "USE_FALLBACK=0"

:parse_args
if "%~1"=="" goto run_update
if /i "%~1"=="--ignore" (
    set "PS_ARGS=!PS_ARGS! -Ignore"
)
if /i "%~1"=="--help" (
    set "PS_ARGS=!PS_ARGS! -Help"
)
if /i "%~1"=="--fallback" (
    set "USE_FALLBACK=1"
)
shift
goto parse_args

:run_update
REM First try to download the latest pre-built cache from the official repo
echo :: [Info] :: Attempting to download latest Python versions cache...

REM Use a simple PowerShell command to download the cache
powershell.exe -ExecutionPolicy Bypass -Command "& {try { $url = 'https://github.com/pyenv-win/pyenv-win/releases/latest/download/versions.xml'; if (-not $url) { $url = 'https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/share/pyenv-win/versions.xml' }; $dest = '%SCRIPT_DIR%..\share\pyenv-win\versions.xml'; $dir = Split-Path $dest -Parent; if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }; Write-Host ':: [Info] :: Downloading from: ' $url; Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop; if ((Test-Path $dest) -and (Get-Item $dest).Length -gt 0) { $content = Get-Content $dest -Raw; $count = ([regex]::Matches($content, '<Version')).Count; Write-Host ':: [Info] :: Successfully downloaded cache with' $count 'Python installers.'; Write-Host ':: [Info] :: Cache saved to:' $dest; exit 0 } else { throw 'Downloaded file is empty' } } catch { Write-Host ':: [Warning] :: Failed to download pre-built cache:' $_.Exception.Message; exit 1 } }"

REM Check if download was successful
if %ERRORLEVEL% equ 0 (
    echo :: [Info] :: Python versions cache updated successfully using pre-built cache.
    goto :end
)

REM If download failed, try the optimized PowerShell script as fallback
echo :: [Info] :: Pre-built cache download failed, trying optimized PowerShell fallback...
if exist "%SCRIPT_DIR%pyenv-update-optimized.ps1" (
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%pyenv-update-optimized.ps1" %PS_ARGS%
    if !ERRORLEVEL! equ 0 (
        echo :: [Info] :: Python versions cache updated successfully using optimized PowerShell script.
        goto :end
    )
)

REM If optimized script failed, try the original PowerShell script
echo :: [Info] :: Optimized script failed, trying original PowerShell fallback...
if exist "%SCRIPT_DIR%pyenv-update.ps1" (
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%pyenv-update.ps1" %PS_ARGS%
    if !ERRORLEVEL! equ 0 (
        echo :: [Info] :: Python versions cache updated successfully using original PowerShell script.
        goto :end
    )
)

REM If all else fails, try VBScript (may fail on Windows 11)
echo :: [Warning] :: PowerShell methods failed, trying VBScript fallback...
echo :: [Warning] :: Note: VBScript may not work properly on Windows 11
cscript //nologo "%SCRIPT_DIR%pyenv-update.vbs" %*

:end
exit /b %ERRORLEVEL%
