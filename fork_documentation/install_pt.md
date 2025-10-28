# Instalacao deste fork no Windows

- Nao precisa de admin.
- PATH (bin e shims) e ajustado pelo instalador.
- O cache de versoes e atualizado apos a instalacao.

## Metodo 0 - One-liner PowerShell (recomendado, resiliente)

```pwsh
$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}
```

Respeitando a politica de execucao:
- Verifique a politica atual: `Get-ExecutionPolicy -List`
- Se scripts estiverem bloqueados, prefira uma execucao temporaria (nao altera a politica da maquina):
  ```pwsh
  PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
  ```

## Metodo 0b - Pelo CMD (sem alterar politica do PowerShell)

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
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
- Pelo pyenv: `pyenv remove`
  - Sempre pede confirmação e em seguida remove tudo em `%USERPROFILE%\\.pyenv\\pyenv-win` (pyenv + versões + cache).
  - Não altera PATH nem perfil de shell automaticamente; imprime até 4 one‑liners (PowerShell, CMD, Git Bash) com a permissão necessária (Usuário/Admin) para você ajustar o PATH e verificar a configuração do shell.

Comportamento
- Best-effort e sem alterar PATH/perfil automaticamente: o doctor e o desinstalador apenas sugerem mudanças com one‑liners.


Logs
- Instalacao/desinstalacao de versoes grava em %USERPROFILE%\\.pyenv\\pyenv-win\\pyenv-actions.log com timestamp.



