# Notas de release - indice de versoes no Windows

## Instalacao

- One-liner PowerShell (resiliente):
  ```pwsh
  $u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}
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
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0
```
```pwsh
cscript //nologo %USERPROFILE%\.pyenv\pyenv-win\libexec\pyenv-install.vbs 3.14.0-arm64
```

### Tabela de comandos (apos instalar)
- Dica: 'pyenv install 3.13' resolve para a ultima 3.13.x da sua arquitetura; 'pyenv install 3' resolve para a ultima 3.x.y.


| Acao               | Comando                 |
|--------------------|-------------------------|
| Listar instalados  | `pyenv versions`        |
| Listar disponiveis | `pyenv install -l`      |
| Instalar versao    | `pyenv install 3.14.0`  |
| Desinstalar versao | `pyenv uninstall 3.14.0`|
| Definir global     | `pyenv global 3.14.0`   |
| Definir local      | `pyenv local 3.14.0`    |
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

## Troubleshooting

- pyenv nao encontrado apos instalar
  - Reabra o terminal ou exporte para esta sessao apenas:
    ```pwsh
    $env:PYENV = "$HOME\.pyenv\pyenv-win"
    $env:Path  = "$env:PYENV\bin;$env:PYENV\shims;$env:Path"
    where pyenv
    ```
- Script desabilitado (PSSecurityException)
  - Rode o instalador com bypass apenas no processo:
    ```pwsh
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
    ```
  - Ou pelo CMD:
    ```cmd
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}"
    ```
- Python resolvendo para App Installer alias
  - Desative os aliases do Python no Windows (Manage App Execution Aliases).
- Entradas antigas do pyenv no PATH
  - Remova outras entradas de bin/shims do pyenv-win; mantenha este fork primeiro no PATH do usuario.
- Por tras de proxy
  - Defina `http_proxy` e `https_proxy` antes de instalar/atualizar.
