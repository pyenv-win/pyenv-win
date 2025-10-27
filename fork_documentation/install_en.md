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
- From pyenv: `pyenv remove` (default KeepVersions). Interactive prompt offers Partial/Full/No; `--full` sets default to Full.

- Keep versions (removes PATH/profile only):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode KeepVersions`
  - CMD: `uninstall.cmd`
- Full removal (delete `%USERPROFILE%\\.pyenv\\pyenv-win`):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode Full`

Behavior
- Best-effort: never abort. Doctor warns about Machine PATH; uninstaller attempts to fix Machine PATH if elevated.
- Backups: before any change to PATH/profile, timestamped backups are written under `%USERPROFILE%\\.pyenv\\pyenv-win`.


Logs
- Version install/uninstall append to %USERPROFILE%\\.pyenv\\pyenv-win\\pyenv-actions.log with timestamps.



