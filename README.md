# Fork README [![Release](https://img.shields.io/github/v/release/mauriciomenon/pyenv-win_adaptado)](https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest)

- Documentacao em Portugues: [install pt](fork_documentation/install_pt.md)



## TLDR

Recommended:
- One-liner PowerShell (no admin):
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```

Execution policy friendly options:
- Check policy first: `Get-ExecutionPolicy -List`
- If scripts are blocked, prefer temporary run (no global change):
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile $env:TEMP\install-pyenv-win.ps1; & $env:TEMP\install-pyenv-win.ps1"
  ```
- From CMD (no PowerShell policy change):
  ```cmd
  curl -L -o %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
  ```
  ```cmd
  wget -O %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
  ```
  ```cmd
  certutil -urlcache -split -f https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 %TEMP%\install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
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
- From pyenv: `pyenv remove` (defaults to KeepVersions). Use `pyenv remove --full` for full removal.

- Keep versions (preserve downloads and installed Pythons; remove PATH/profile only):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode KeepVersions`
  - CMD: run `uninstall.cmd`
- Full removal (delete everything under `%USERPROFILE%\\.pyenv\\pyenv-win`, including versions and cache):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode Full`

Behavior
- Best-effort: never abort operations. Doctor warns about Machine PATH; uninstaller attempts to fix Machine PATH if elevated.
- Backups: before any change to PATH/profile, timestamped backups are written under `%USERPROFILE%\\.pyenv\\pyenv-win`.
- Logging: install/uninstall of Python versions append to `%USERPROFILE%\\.pyenv\\pyenv-win\\pyenv-actions.log` with timestamps.


