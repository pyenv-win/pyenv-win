# Instalacao deste fork no Windows

- Nao precisa de admin.
- PATH (bin e shims) e ajustado pelo instalador.
- O cache de versoes e atualizado apos a instalacao.

## Metodo 0 - One-liner PowerShell (recomendado)

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

Respeitando a politica de execucao:
- Verifique a politica atual: `Get-ExecutionPolicy -List`
- Se scripts estiverem bloqueados, prefira uma execucao temporaria (nao altera a politica da maquina):
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1' -OutFile $env:TEMP\install-pyenv-win.ps1; & $env:TEMP\install-pyenv-win.ps1"
  ```

## Metodo 0b - Pelo CMD (sem alterar politica do PowerShell)

```cmd
curl -L -o %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
```
```cmd
wget -O %TEMP%\install-pyenv-win.ps1 https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
```
```cmd
certutil -urlcache -split -f https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1 %TEMP%\install-pyenv-win.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File %TEMP%\install-pyenv-win.ps1
```

Alternativa: use o helper incluso `install.cmd` (duplo clique ou execute no CMD). Ele usa bypass apenas no processo do instalador.

## Metodo 1 - Git clone

```pwsh
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list | Select-Object -First 20
```

```cmd
git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git %USERPROFILE%\.pyenv\pyenv-win
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
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0
  ```
- Instalar ARM64:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0-arm64
  ```

## Comandos apos instalar (pyenv)

| Acao               | Comando                  |
|--------------------|--------------------------|
| Listar instalados  | `pyenv versions`         |
| Listar disponiveis | `pyenv install -l`       |
| Instalar versao    | `pyenv install 3.14.0`   |
| Desinstalar        | `pyenv uninstall 3.14.0` |
| Definir global     | `pyenv global 3.14.0`    |
| Definir local      | `pyenv local 3.14.0`     |
| Mostrar versao     | `pyenv version`          |
| Qual python        | `pyenv which python`     |
| Recriar shims      | `pyenv rehash`           |
| Doctor (verificar PATH) | `pyenv doctor`      |

Desinstalar
- Preservar versões (remove apenas PATH/perfil):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode KeepVersions`
  - CMD: `uninstall.cmd`
- Remoção completa (apaga `%USERPROFILE%\\.pyenv\\pyenv-win` inteiro):
  - PowerShell: `& .\\pyenv-win\\uninstall-pyenv-win.ps1 -Mode Full`

Comportamento
- Best-effort: nunca aborta. O doctor avisa sobre PATH de Máquina; o desinstalador tenta corrigir se estiver elevado.
- Backups: antes de qualquer alteração no PATH/perfil, backups com timestamp são salvos em `%USERPROFILE%\\.pyenv\\pyenv-win`.

