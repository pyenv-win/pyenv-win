## Instalação do pyenv-win (fork adaptado) — Windows

Este guia descreve como instalar e usar este fork do pyenv-win de forma repetível, espelhando o processo do projeto original. Inclui métodos via PowerShell, Git e Zip, além dos comandos básicos de atualização, listagem e instalação de versões do Python.

### Pré‑requisitos
- Windows 10/11 com PowerShell.
- Acesso à Internet para baixar o repositório e instaladores do Python.

### Estrutura de diretórios
- Padrão de instalação do pyenv-win: `%USERPROFILE%\.pyenv\pyenv-win`
- Subpastas importantes:
  - `bin` e `shims` (devem estar no PATH do usuário)
  - `libexec` (scripts internos)

### Método 1 — PowerShell (Zip do GitHub Release deste fork)
1) Abrir PowerShell “como usuário” (não precisa administrador).
2) Criar a pasta base (se não existir):
   ```pwsh
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.pyenv" | Out-Null
   ```
3) Baixar o ZIP da tag desejada (ex.: v3.1.2):
   ```pwsh
   $ver = 'v3.1.2'
   $zipUrl = "https://github.com/mauriciomenon/pyenv-win_adaptado/archive/refs/tags/$ver.zip"
   $zipOut = "$env:USERPROFILE\.pyenv\pyenv-win.zip"
   (New-Object System.Net.WebClient).DownloadFile($zipUrl, $zipOut)
   ```
4) Extrair e posicionar na pasta padrão:
   ```pwsh
   $dest = "$env:USERPROFILE\.pyenv"
   Microsoft.PowerShell.Archive\Expand-Archive -Path $zipOut -DestinationPath $dest -Force
   Move-Item -Force -Path "$dest\pyenv-win_adaptado-$ver\*" -Destination "$dest"
   Remove-Item -Recurse -Force "$dest\pyenv-win_adaptado-$ver"
   Remove-Item -Force $zipOut
   ```
5) Garantir que o conteúdo esteja em `%USERPROFILE%\.pyenv\pyenv-win`.
6) Ajustar PATH do usuário (sem duplicar):
   ```pwsh
   $bin   = "$env:USERPROFILE\.pyenv\pyenv-win\bin"
   $shims = "$env:USERPROFILE\.pyenv\pyenv-win\shims"
   $path  = [System.Environment]::GetEnvironmentVariable('PATH','User') -split ';'
   $path  = @($bin,$shims) + ($path | Where-Object { $_ -and $_ -ne $bin -and $_ -ne $shims })
   [System.Environment]::SetEnvironmentVariable('PATH',($path -join ';'),'User')
   ```
7) Atualizar cache local de versões e validar:
   ```pwsh
   cscript //nologo "$env:USERPROFILE\.pyenv\pyenv-win\libexec\pyenv-update.vbs" --ignore
   cscript //nologo "$env:USERPROFILE\.pyenv\pyenv-win\libexec\pyenv-install.vbs" --list | Select-Object -First 20
   ```

### Método 2 — Git (repetível e versionado)
1) Clonar este fork diretamente na pasta padrão:
   ```pwsh
   git clone https://github.com/mauriciomenon/pyenv-win_adaptado.git "$env:USERPROFILE\.pyenv\pyenv-win"
   ```
2) Ajustar PATH do usuário (se necessário):
   ```pwsh
   $bin   = "$env:USERPROFILE\.pyenv\pyenv-win\bin"
   $shims = "$env:USERPROFILE\.pyenv\pyenv-win\shims"
   $path  = [System.Environment]::GetEnvironmentVariable('PATH','User') -split ';'
   $path  = @($bin,$shims) + ($path | Where-Object { $_ -and $_ -ne $bin -and $_ -ne $shims })
   [System.Environment]::SetEnvironmentVariable('PATH',($path -join ';'),'User')
   ```
3) Atualizar cache local e validar:
   ```pwsh
   cscript //nologo "$env:USERPROFILE\.pyenv\pyenv-win\libexec\pyenv-update.vbs" --ignore
   cscript //nologo "$env:USERPROFILE\.pyenv\pyenv-win\libexec\pyenv-install.vbs" --list | Select-Object -First 20
   ```

### Método 3 — Zip manual (sem Git)
- Igual ao Método 1, baixando o ZIP do release deste fork e posicionando o conteúdo em `%USERPROFILE%\.pyenv\pyenv-win`, depois ajustando o PATH e rodando o `pyenv-update.vbs`.

### Comandos de uso (iguais ao original)
- Atualizar base:
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-update.vbs --ignore
  ```
- Listar versões (filtráveis):
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs --list
  ```
- Instalar versão (amd64):
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9
  ```
- Instalar versão (ARM64):
  ```pwsh
  cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.13.9-arm64
  ```
- Demais comandos (`global`, `local`, `rehash`) seguem o padrão pyenv-win.

### Observações
- Este fork já atualiza o cache automaticamente ao final do script de instalação interno; nos métodos manuais, execute o `pyenv-update.vbs` após instalar.
- Arquitetura padrão: em hosts x64, amd64 é implícito; para ARM64, use o sufixo `-arm64`.

