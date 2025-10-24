# Release notes - Windows versions index update

## Install

- One-liner PowerShell:
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```
- Click to install: run `install.cmd` in this repository.
- No admin required. PATH is set, cache is refreshed.

## Changes vs original

- Windows versions index based on FTP parsing, with direct fallback for installers in subfolders `amd64/`, `arm64/`, `win32`.
- CPython only and stable only: removed pypy, graalpy, and pre-releases (rc, alpha, beta).
- ARM naming standardized to `-arm64`.
- Installer refreshes the version cache at the end.

## Basic commands

- Update cache: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore`
- List: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list`
- Install amd64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9`
- Install ARM64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64`

