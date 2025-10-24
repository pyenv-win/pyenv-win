# Notas de release - indice de versoes no Windows

## Instalacao

- One-liner PowerShell:
  ```pwsh
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
  ```
- Clique e instale: rode `install.cmd` neste repositorio.
- Nao precisa admin. PATH e ajustado.

## Mudancas em relacao ao original

- Indice de versoes do Windows com parsing de FTP e fallback direto para instaladores nas subpastas `amd64/`, `arm64/`, `win32`.
- Somente CPython e somente estavel: removidos pypy, graalpy e pre-releases (rc, alpha, beta).
- Nome ARM padrao `-arm64`.
- Sem update automatico no install. Rode `pyenv update` quando precisar.

## Comandos basicos

```pwsh
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list
```
```pwsh
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
```
```pwsh
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9
```
```pwsh
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64
```

### Tabela de comandos (apos instalar)

| Acao               | Comando                 |
|--------------------|-------------------------|
| Listar instalados  | `pyenv versions`        |
| Listar disponiveis | `pyenv install -l`      |
| Instalar versao    | `pyenv install 3.13.9`  |
| Desinstalar versao | `pyenv uninstall 3.13.9`|
| Definir global     | `pyenv global 3.13.9`   |
| Definir local      | `pyenv local 3.13.9`    |
| Mostrar versao     | `pyenv version`         |
| Qual python        | `pyenv which python`    |
| Recriar shims      | `pyenv rehash`          |

## Documentacao completa

- [install_en.md](../fork_documentation/install_en.md) - guia instalacao EN
- [install_pt.md](../fork_documentation/install_pt.md) - guia instalacao PT
- [install_en.txt](../fork_documentation/install_en.txt) - instalacao texto EN
- [install_pt.txt](../fork_documentation/install_pt.txt) - instalacao texto PT
- [project_structure_en.md](../fork_documentation/project_structure_en.md) - estrutura projeto EN
- [project_structure_pt.md](../fork_documentation/project_structure_pt.md) - estrutura projeto PT
