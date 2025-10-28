# Install this fork on Windows

- No admin required.
- PATH (bin and shims) is set by the installer.
- Version cache is refreshed after install.

## Method 0 - One-liner PowerShell (recommended, resilient)

```pwsh
$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}
```

Execution policy friendly:
- Check policy first: `Get-ExecutionPolicy -List`
- If scripts are blocked, prefer a temporary run that doesn’t change your machine policy:
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
  ```

## Method 0b - From Command Prompt (no PowerShell policy changes)

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
```

Alternatively, use the included helper: `install.cmd` (double-click or run from CMD). It uses a process-scoped policy bypass only for the installer run.

## Method 1 - Git clone

```pwsh
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list | Select-Object -First 20
```

```cmd
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
```

## Method 2 - Release ZIP

1. Download the latest release: https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest
2. Extract into `%USERPROFILE%\.pyenv\pyenv-win`.
3. Run the update and list commands above.

## Use

- Update cache:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
  ```
- List versions:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list
  ```
- Install amd64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0
  ```
- Install ARM64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0-arm64
  ```

## Commands after install (pyenv)

| Action           | Command                  |
|------------------|--------------------------|
| List installed   | `pyenv versions`         |
| List available   | `pyenv install -l`       |
| Install version  | `pyenv install 3.14.0`   |
| Uninstall        | `pyenv uninstall 3.14.0` |
| Set global       | `pyenv global 3.14.0`    |
| Set local        | `pyenv local 3.14.0`     |
| Show version     | `pyenv version`          |
| Which python     | `pyenv which python`     |
| Rebuild shims    | `pyenv rehash`           |
| Doctor (check PATH) | `pyenv doctor`        |

Uninstall
- From pyenv: `pyenv remove`
  - Always prompts for confirmation and then removes everything under `%USERPROFILE%\\.pyenv\\pyenv-win` (pyenv + versions + cache).
  - Does not change PATH or shell profile automatically; prints up to 4 one‑liners (PowerShell, CMD, Git Bash) with the required privilege so you can adjust PATH and check your shell config yourself.

Behavior
- Best-effort and non-destructive to system PATH/profile: doctor and uninstaller only suggest changes with one‑liners.


Logs
- Version install/uninstall append to %USERPROFILE%\\.pyenv\\pyenv-win\\pyenv-actions.log with timestamps.



