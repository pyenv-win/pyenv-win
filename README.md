# Fork README [![Release](https://img.shields.io/github/v/release/mauriciomenon/pyenv-win_adaptado)](https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest)

- Documentacao em Portugues: [install pt](fork_documentation/install_pt.md)



## TLDR

Recommended:
- One-liner PowerShell (resilient, no admin):
  ```pwsh
  $u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}
  ```

Execution policy friendly options:
- Check policy first: `Get-ExecutionPolicy -List`
- If scripts are blocked, prefer temporary run (no global change):
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
  ```
- From CMD (no PowerShell policy change):
  ```cmd
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
  ```

Method 2:
- Click to install: run `install.cmd` (or `install.ps1`)

Method 3:
- Git clone: `git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win`
  ```cmd
  git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
  ```

Method 4:
- Release ZIP: latest release https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest

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
  - Does not change PATH or shell profile automatically; prints up to 4 one‑liners (PowerShell, CMD, Git Bash) with the required privilege (User/Admin) so you can adjust PATH and check your shell config yourself.

Behavior
- Best-effort and non-destructive to system PATH/profile: doctor and uninstaller only suggest changes with one‑liners.



