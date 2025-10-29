@echo off
setlocal
chcp 65001 >nul 2>&1

:: Simple health checks for PATH and pyenv layout
set "user_root=%USERPROFILE%\.pyenv\pyenv-win"
set "shim=%~dp0..\shims\python.bat"

if /i "%~1"=="--aggressive-fix" goto :aggressive_fix

if not exist "%shim%" (
  echo INFO: pyenv shims not found at "%shim%". Try: pyenv rehash
  goto :eof
)

call :normalizepath "%shim%" shim
set "python_where="
for /f "delims=" %%a in ('where python 2^>nul') do (
  if /i "%shim%"=="%%~dpfa" goto :ok
  call :set_python_where %%~dpfa
)

if not "%python_where%"=="" (
  call :bad_path "%python_where%"
  goto :eof
)

:check_machine_path
for /f "delims=" %%m in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable(''Path'',''Machine'')"') do set "MACHINE_PATH=%%m"
set "__ERRSYS="
echo %MACHINE_PATH% | findstr /I /C:".pyenv\pyenv-win\bin" >nul && set "__ERRSYS=1"
if not defined __ERRSYS echo %MACHINE_PATH% | findstr /I /C:".pyenv\pyenv-win\shims" >nul && set "__ERRSYS=1"
if defined __ERRSYS (
  echo [WARN] pyenv found in System (Machine) PATH. Not recommended.
  echo Suggestion (PowerShell Admin):
  echo   $mp = [Environment]::GetEnvironmentVariable('Path','Machine')
  echo   $mp = ($mp -split ';' ^| %% { $_ ^|? { $_ -notmatch '\\.pyenv\\pyenv-win\\(bin^|shims)' } }) -join ';'
  echo   [Environment]::SetEnvironmentVariable('Path',$mp,'Machine')
)

:ok
echo OK: pyenv shims appear first in PATH.
goto :eof

:: aggressive fix (hidden): append init block to PowerShell profile and reload
:aggressive_fix
set "__tmp_ps1=%TEMP%\pyenv_doctor_fix_%RANDOM%.ps1"
>"%__tmp_ps1%" echo $ErrorActionPreference = "Stop"
>>"%__tmp_ps1%" echo $profileDir = Split-Path -Parent $PROFILE
>>"%__tmp_ps1%" echo if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir ^| Out-Null }
>>"%__tmp_ps1%" echo if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force ^| Out-Null }
>>"%__tmp_ps1%" echo $base = "$env:USERPROFILE\.pyenv\pyenv-win"
>>"%__tmp_ps1%" echo if (-not (Test-Path "$base\bin") -or -not (Test-Path "$base\shims")) { Write-Host "pyenv user install not found at $base"; exit 1 }
>>"%__tmp_ps1%" echo @"
>>"%__tmp_ps1%" echo # pyenv-win (doctor fix)
>>"%__tmp_ps1%" echo $env:PYENV_ROOT = '$base'
>>"%__tmp_ps1%" echo if (Test-Path "$env:PYENV_ROOT\bin" -and (Test-Path "$env:PYENV_ROOT\shims")) {
>>"%__tmp_ps1%" echo ^    if ($env:PATH -notmatch [regex]::Escape("$env:PYENV_ROOT\bin")) {
>>"%__tmp_ps1%" echo ^        $env:PATH = "$env:PYENV_ROOT\bin;$env:PYENV_ROOT\shims;" + $env:PATH
>>"%__tmp_ps1%" echo ^    }
>>"%__tmp_ps1%" echo }
>>"%__tmp_ps1%" echo "@^" ^| Add-Content -Path $PROFILE
>>"%__tmp_ps1%" echo . $PROFILE
powershell -NoProfile -ExecutionPolicy Bypass -File "%__tmp_ps1%"
set "ec=%ERRORLEVEL%"
del /q "%__tmp_ps1%" >nul 2>&1
if not "%ec%"=="0" exit /b %ec%
echo Applied aggressive fix to PowerShell profile. Open a new shell or run:  . $PROFILE
exit /b 0

:normalizepath
set "%~2=%~dpf1"
goto :eof

:set_python_where
if "%python_where%"=="" set "python_where=%*"
goto :eof

:bad_path
set "bad_python=%~1"
set "bad_dir=%~dp1"
echo [93mWARN: Detected [95m%bad_python%[93m before pyenv shims in PATH.[0m
echo [93mPython may not switch with 'pyenv global/local'.[0m
echo.
echo [96mSuggestions (PowerShell one-liners):[0m
echo   1^) Current session only: prepend user pyenv to PATH
echo      [90m$env:PYENV_ROOT = "$env:USERPROFILE\.pyenv\pyenv-win" ^; $env:PATH = "$env:PYENV_ROOT\bin;$env:PYENV_ROOT\shims;" ^+ $env:PATH[0m
echo   2^) Persist in profile and reload
echo      [90mif^(^!^(Test-Path $PROFILE^)^)^{^ New-Item -ItemType File -Path $PROFILE -Force ^| Out-Null ^}^; Add-Content -Path $PROFILE -Value "`n# pyenv-win`n$env:PYENV_ROOT = '$env:USERPROFILE\.pyenv\pyenv-win'`n$env:PATH = $env:PYENV_ROOT ^+ '\bin;' ^+ $env:PYENV_ROOT ^+ '\shims;' ^+ $env:PATH`n" ^; . $PROFILE[0m
echo   3^) Remove Scoop pyenv from PATH (session)
echo      [90m$env:PATH = ^(($env:PATH -split ';'^) ^| Where-Object { $_ -notmatch '\\scoop\\apps\\pyenv\\current\\pyenv-win' }^) -join ';'[0m
echo.
echo [93mAfter adjusting PATH, run:  pyenv rehash[0m
goto :eof

