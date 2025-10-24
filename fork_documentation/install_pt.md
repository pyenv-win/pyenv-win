# Instalacao deste fork no Windows

- Nao precisa de admin.
- PATH (bin e shims) e ajustado pelo instalador.
- O cache de versoes e atualizado apos a instalacao.

## Metodo 0 - One-liner PowerShell (recomendado)

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

## Metodo 1 - Git clone

```pwsh
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list | Select-Object -First 20
```

## Metodo 2 - ZIP do release

1. Baixe o ultimo release: https://github.com/mauriciomenon/pyenv-win_adaptado/releases/latest
2. Extraia em `%USERPROFILE%\.pyenv\pyenv-win`.
3. Rode os comandos de update e list acima.

## Uso

- Atualizar cache:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
  ```
- Listar versoes:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list
  ```
- Instalar amd64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9
  ```
- Instalar ARM64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64
  ```

## Comandos apos instalar (pyenv)

| Acao             | Comando                          |
|------------------|----------------------------------|
| Listar instalados| `pyenv versions`                 |
| Listar disponiveis| `pyenv install -l`              |
| Instalar versao  | `pyenv install 3.13.9`           |
| Desinstalar      | `pyenv uninstall 3.13.9`         |
| Definir global   | `pyenv global 3.13.9`            |
| Definir local    | `pyenv local 3.13.9`             |
| Mostrar versao   | `pyenv version`                  |
| Qual python      | `pyenv which python`             |
| Recriar shims    | `pyenv rehash`                   |

```pwsh
# Listar instalados
pyenv versions

# Listar disponiveis
pyenv install -l

# Instalar versao
pyenv install 3.13.9

# Desinstalar versao
pyenv uninstall 3.13.9

# Definir global
pyenv global 3.13.9

# Definir local
pyenv local 3.13.9

# Mostrar versao
pyenv version

# Qual python
pyenv which python

# Recriar shims
pyenv rehash
```
