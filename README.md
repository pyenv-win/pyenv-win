# Fork README [![Release](https://img.shields.io/github/v/release/mauriciomenon/pyenv-win_adaptado)](https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest)

- Documentacao em Portugues: [install pt](fork_documentation/install_pt.md)



## TLDR

Recommended:
- One-liner PowerShell (no admin, simple):
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile "$env:TEMP\install-pyenv-win.ps1"; & "$env:TEMP\install-pyenv-win.ps1"
  ```
- Alternative with curl (if available):
  ```pwsh
  curl -L https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 -o "$env:TEMP\install-pyenv-win.ps1"; & "$env:TEMP\install-pyenv-win.ps1"
  ```
- Alternative with wget (if available):
  ```pwsh
  wget https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 -O "$env:TEMP\install-pyenv-win.ps1"; & "$env:TEMP\install-pyenv-win.ps1"
  ```
- Native PowerShell with WebClient:
  ```pwsh
  (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1', "$env:TEMP\install-pyenv-win.ps1"); & "$env:TEMP\install-pyenv-win.ps1"
  ```
- Native PowerShell with HttpClient (PowerShell 5.1+):
  ```pwsh
  $client = New-Object System.Net.Http.HttpClient; $response = $client.GetAsync('https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1').Result; $content = $response.Content.ReadAsStringAsync().Result; Set-Content "$env:TEMP\install-pyenv-win.ps1" $content; & "$env:TEMP\install-pyenv-win.ps1"
  ```

Execution policy friendly options:
- Check policy first: `Get-ExecutionPolicy -List`
- If scripts are blocked, prefer temporary run (no global change):
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
  ```
- From CMD (no PowerShell policy change):
  ```cmd
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile $env:TEMP\install-pyenv-win.ps1; & $env:TEMP\install-pyenv-win.ps1"
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

Method 5: Manual download (no command line tools)
1. Download ZIP from latest release: https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest
2. Extract to `%USERPROFILE%\.pyenv\pyenv-win`
3. Add to PATH: `%USERPROFILE%\.pyenv\pyenv-win\bin` and `%USERPROFILE%\.pyenv\pyenv-win\shims`

Method 6: Windows Explorer (GUI)
1. Create folder: `C:\Users\[YourUsername]\.pyenv\pyenv-win`
2. Download and extract release ZIP into that folder
3. Right-click "This PC" → Properties → Advanced system settings → Environment Variables
4. Add to User PATH:
   - `%USERPROFILE%\.pyenv\pyenv-win\bin`
   - `%USERPROFILE%\.pyenv\pyenv-win\shims`

Install location and behavior
- Installs to `%USERPROFILE%\.pyenv\pyenv-win`.
- At the end of install, you are offered to auto-install Python (latest stable, or latest 3.10/3.11/3.12/3.13) and set it as global.
- Uninstall via `pyenv remove` prompts and removes `%USERPROFILE%\.pyenv\pyenv-win`. If nothing exists there, it prints: `pyenv remove: nothing to remove at "%USERPROFILE%\.pyenv\pyenv-win"`.

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



