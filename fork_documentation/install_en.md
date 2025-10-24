# Install this fork on Windows

- No admin required.
- PATH (bin and shims) is set by the installer.
- Version cache is refreshed after install.

## Method 0 - One-liner PowerShell (recommended)

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

## Method 1 - Git clone

```pwsh
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list | Select-Object -First 20
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
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9
  ```
- Install ARM64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64
  ```

