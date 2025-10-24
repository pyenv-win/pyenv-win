# Release notes - Windows versions index update

## TLDR - install - no admin

- One-liner PowerShell:
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```
- Click to install: run `install.cmd`.
- Commands:
  - Update cache: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore`
  - List: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list`
  - Install amd64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9`
  - Install ARM64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64`

## Changes vs original

- FTP parsing with direct fallback, supports `amd64/`, `arm64/`, `win32`.
- Filters: remove pypy, graalpy, rc, alpha, beta.
- Synthesizes direct installer entries 3.9 to 3.30, patches 0..30.
- ARM naming `-arm64`.
- No automatic versions update on install. Run `pyenv update` when needed.