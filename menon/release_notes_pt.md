# Notas de release - indice de versoes no Windows

## Instalacao

- One-liner PowerShell:
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```
- Clique e instale: rode `install.cmd` neste repositorio.
- Nao precisa admin. PATH e ajustado e o cache e atualizado.

## Mudancas em relacao ao original

- Indice de versoes do Windows com parsing de FTP e fallback direto para instaladores nas subpastas `amd64/`, `arm64/`, `win32`.
- Somente CPython e somente estavel: removidos pypy, graalpy e pre-releases (rc, alpha, beta).
- Nome ARM padrao `-arm64`.
- O instalador atualiza o cache ao final.

## Comandos basicos

- Atualizar cache: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore`
- Listar: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list`
- Instalar amd64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9`
- Instalar ARM64: `cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64`

