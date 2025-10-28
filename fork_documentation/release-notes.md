# Release notes - Windows versions index update

## TLDR - install - no admin

- One-liner PowerShell:
  ```pwsh
  $u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}
  ```
- Click to install: run `install.cmd`.
- Commands:
  - Update cache: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore`
  - List: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list`
  - Install amd64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0`
  - Install ARM64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0-arm64`

## Changes vs original
- Tip: 'pyenv install 3.13' resolves to the latest 3.13.x for your arch; 'pyenv install 3' resolves to the latest 3.x.y.


- FTP parsing with direct fallback, supports `amd64/`, `arm64/`, `win32`.
- Filters: remove pypy, graalpy, rc, alpha, beta.
- Synthesizes direct installer entries 3.9 to 3.30, patches 0..30.
- ARM naming `-arm64`.
- No automatic versions update on install. Run `pyenv update` when needed.

## Troubleshooting

- pyenv not found after install
  - Reopen the terminal or export for this session only:
    ```pwsh
    $env:PYENV = "$HOME\.pyenv\pyenv-win"
    $env:Path  = "$env:PYENV\bin;$env:PYENV\shims;$env:Path"
    where pyenv
    ```
- Script is disabled (PSSecurityException)
  - Run installer with a process-scoped bypass:
    ```pwsh
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
    ```
  - Or from CMD:
    ```cmd
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
    ```
- Python resolves to App Installer alias
  - Disable Python aliases in Windows: Manage App Execution Aliases.
- Old pyenv entries in PATH
  - Remove other pyenv-win bin/shims from PATH; keep this fork first (user PATH).
- Behind proxy
  - Set `http_proxy` and `https_proxy` before install/update.
