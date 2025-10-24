# Release notes - Windows versions index update

## Install

- One-liner PowerShell:
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```
- Click to install: run `install.cmd` in this repository.
- No admin required.

## Changes vs original

- Windows versions index based on FTP parsing, with direct fallback for installers in subfolders `amd64/`, `arm64/`, `win32`.
- CPython only and stable only: removed pypy, graalpy, and pre-releases (rc, alpha, beta).
- ARM naming standardized to `-arm64`.
- Installer does not auto update versions; run `pyenv update` when needed.

## Basic commands

```pwsh
# List
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list

# Update cache
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore

# Install amd64
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9

# Install ARM64
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64
```

## Full documentation

- [install_en.md](../fork_documentation/install_en.md) - install guide EN
- [install_pt.md](../fork_documentation/install_pt.md) - install guide PT
- [install_en.txt](../fork_documentation/install_en.txt) - install text EN
- [install_pt.txt](../fork_documentation/install_pt.txt) - install text PT
- [project_structure_en.md](../fork_documentation/project_structure_en.md) - project structure EN
- [project_structure_pt.md](../fork_documentation/project_structure_pt.md) - project structure PT
