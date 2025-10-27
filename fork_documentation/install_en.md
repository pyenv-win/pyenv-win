# Install this fork on Windows

- No admin required.
- PATH (bin and shims) is set by the installer.
- Version cache is refreshed after install.

## Method 0 - One-liner PowerShell (recommended)

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

Execution policy friendly:
- Check policy first: `Get-ExecutionPolicy -List`
- If scripts are blocked, prefer a temporary run that doesn’t change your machine policy:
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile $env:TEMP\install-pyenv-win.ps1; & $env:TEMP\install-pyenv-win.ps1"
  ```

## Method 0b - From Command Prompt (no PowerShell policy changes)

```cmd
curl -L -o %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
```
```cmd
wget -O %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
```
```cmd
certutil -urlcache -split -f https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 %TEMP%\install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
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
- Keep versions (removes PATH/profile only):
  - PowerShell: `& .\pyenv-win\uninstall-pyenv-win.ps1 -Mode KeepVersions`
  - CMD: `uninstall.cmd`
- Full removal (delete `%USERPROFILE%\.pyenv\pyenv-win`):
  - PowerShell: `& .\pyenv-win\uninstall-pyenv-win.ps1 -Mode Full`

System PATH is not supported. `pyenv doctor` errors if Machine PATH contains pyenv entries.

- Tip: 'pyenv install 3.13' resolves to the latest 3.13.x for your arch; 'pyenv install 3' resolves to the latest 3.x.y.

Post-install verification
- Default behavior: installation is considered successful when the target folder and `python.exe` exist. If `Scripts/pip.exe` is missing, pyenv-win attempts `python -m ensurepip -U` and continues with a warning. The version check using `python -V` is also warning-only.
- Strict mode: pass `--strict-verify` to treat missing `pip.exe` or a version mismatch as errors and abort the install.

## Immediate use in the current session

If `pyenv` is not found right after install, either reopen the terminal or export to PATH for this session:
```pwsh
$env:PYENV = "$HOME\.pyenv\pyenv-win"
$env:Path  = "$env:PYENV\bin;$env:PYENV\shims;$env:Path"
pyenv --version
```

CMD fallback to test without PATH changes:
```cmd
"%USERPROFILE%\.pyenv\pyenv-win\bin\pyenv.bat" --version
```

## Troubleshooting

- pyenv not found after install
  - Reopen the terminal or export for this session only:
    ```pwsh
    $env:PYENV = "$HOME\.pyenv\pyenv-win"
    $env:Path  = "$env:PYENV\bin;$env:PYENV\shims;$env:Path"
    where pyenv
    ```
- Script is disabled (PSSecurityException)
  - Run installer with a process-scoped bypass (no global change):
    ```pwsh
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile $env:TEMP\install-pyenv-win.ps1; & $env:TEMP\install-pyenv-win.ps1"
    ```
  - Or from CMD:
    ```cmd
    curl -L -o %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
    ```
- Python resolves to App Installer alias
  - Disable Python aliases in Windows: Manage App Execution Aliases and turn off Python entries.
- Old pyenv entries in PATH
  - Remove other pyenv-win bin/shims from PATH, keep this fork first in user PATH.
- Behind proxy
  - Set `http_proxy` and `https_proxy` env vars before install/update.

