$null = @'
<#
.SYNOPSIS
  Desinstalador interativo do pyenv-win (fluxo único).

.DESCRIPTION
  - Sempre confirma e remove COMPLETAMENTE `%USERPROFILE%\.pyenv\pyenv-win` (pyenv + versões + cache).
  - Não altera PATH nem perfil de shell automaticamente; imprime até 4 one‑liners (PowerShell/CMD/Git Bash)
    com indicação de privilégio (Admin/Usuário) para que o próprio usuário ajuste.
  - Escopo: evitar conflitos com gerenciadores (Scoop/Winget) e manter o shell funcional após a remoção.
    Este script NÃO tenta “consertar” instalações/manutenções feitas por Scoop/Winget de forma automática.

.USAGE
  - Pelo pyenv:  pyenv remove
  - Direto no PowerShell:  & '.\\pyenv-win\\uninstall-pyenv-win.ps1'

.NOTAS
  - A referência a compatibilidade/evitar conflitos com Scoop/Winget fica documentada apenas neste arquivo,
    sem menção em outros locais da documentação/código.
#>
'@

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host $msg -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host $msg -ForegroundColor Red }

$UserRoot = Join-Path $env:USERPROFILE ".pyenv\pyenv-win"
$Bin = Join-Path $UserRoot 'bin'
$Shims = Join-Path $UserRoot 'shims'
$PathsToRemove = @($Bin, $Shims)

function Show-Manual-Remediation {
  Write-Host ''
  Write-Info 'Verificacoes e comandos sugeridos (max 4; nada e executado automaticamente):'

  $mp = [Environment]::GetEnvironmentVariable('Path','Machine')
  $up = [Environment]::GetEnvironmentVariable('Path','User')

  # Motivos (exibidos apenas quando detectados)
  $why = @()
  if ($mp -match '\\scoop\\apps\\pyenv\\current\\pyenv-win' -or $up -match '\\scoop\\apps\\pyenv\\current\\pyenv-win') { $why += 'PATH contem pyenv do Scoop' }
  if ($mp -match '\\WindowsApps' -or $up -match '\\WindowsApps' -or $up -match 'AppData\\Local\\Programs\\Python') { $why += 'PATH contem WindowsApps/winget python' }
  if ($why.Count -gt 0) { Write-Warn ("Porque: " + ($why -join '; ')) }

  # Comandos (copiar e colar)
  Write-Host "  1) PS(Admin)> `$mp=[Environment]::GetEnvironmentVariable('Path','Machine');`$mp=(`$mp -split ';'|?{`$_ -notmatch '\\.pyenv\\pyenv-win\\(bin|shims)'} ) -join ';';[Environment]::SetEnvironmentVariable('Path',`$mp,'Machine')"
  Write-Host "  2) PS(User)>  `$up=[Environment]::GetEnvironmentVariable('Path','User');`$up=(`$up -split ';'|?{`$_ -notmatch '\\.pyenv\\pyenv-win\\(bin|shims)'} ) -join ';';[Environment]::SetEnvironmentVariable('Path',`$up,'User')"
  Write-Host "  3) Bash$>      echo ~/.bashrc    # verifique se nao ha linhas do pyenv"
  Write-Host "  4) CMD>        reg query \"HKCU\\Software\\Microsoft\\Command Processor\" /v AutoRun"
}

function Prompt-Confirm($message, [string]$default = 'N') {
  $ans = ''
  $def = ($default.ToUpper()).Substring(0,1)
  while ($true) {
    $prompt = "${message} (Y/N) [${def}]: "
    Write-Host -NoNewline $prompt
    $ans = Read-Host
    if (-not $ans) { $ans = $def }
    $ans = ($ans.Substring(0,1)).ToUpper()
    if ($ans -in @('Y','N')) { return $ans }
  }
}

function Remove-Files {
  if (-not (Test-Path $UserRoot)) { Write-Info "Nada para remover em $UserRoot"; return }
  if ($Mode -eq 'Full') {
    Remove-Item -LiteralPath $UserRoot -Recurse -Force -ErrorAction SilentlyContinue
    Write-Info "Removido: $UserRoot (pyenv + versions)."
  } else {
    # KeepVersions: remover tudo exceto 'versions'
    $items = Get-ChildItem -LiteralPath $UserRoot -Force -ErrorAction SilentlyContinue
    foreach ($it in $items) {
      if ($it.Name -ieq 'versions') { continue }
      Remove-Item -LiteralPath $it.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Info "Removidos componentes do pyenv; mantido: $($UserRoot + '\\versions')"
  }
}

Write-Info "pyenv-win Uninstaller"

# Fluxo sempre interativo (sem chaves/flags)
$Mode = 'Full'

# 1) Confirmar continuidade
$ans = Prompt-Confirm 'Confirmar desinstalacao do pyenv-win?'
if ($ans -eq 'N') { Write-Info 'Cancelado pelo usuario.'; exit 0 }

# 2) Escopo: sempre remover tudo (pyenv + Pythons)
Write-Info 'Remocao completa: pyenv + todas as versoes instaladas pelo pyenv.'

# 3) Remover arquivos conforme escopo
Remove-Files

# 4) Somente verificar PATH/perfil e sugerir oneliners (max 4)
Show-Manual-Remediation

# Dicas de contorno para erros 429 (GitHub) ao baixar o instalador
function Show-GitHub429-Tips {
  Write-Host ''
  Write-Info 'Se ocorrer 429 (Too Many Requests) ao baixar o instalador:'
  $ps = @'
PS> $u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1'
    $o=Join-Path $env:TEMP 'install-pyenv-win.ps1'
    for($i=1;$i -le 5;$i++){
      try{ Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop; break }
      catch{ if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){
               $ra=$_.Exception.Response.GetResponseHeader('Retry-After'); $s=0; if([int]::TryParse($ra,[ref]$s)){ Start-Sleep -Seconds $s } else { Start-Sleep -Seconds ([int][math]::Pow(2,$i)) }
             } else { throw } }
    }
    if(Test-Path $o){ & $o }
'@
  $cmd = @'
CMD> powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1';$o=Join-Path $env:TEMP 'install-pyenv-win.ps1';for($i=1;$i -le 5;$i++){try{Invoke-WebRequest -UseBasicParsing -Headers @{'User-Agent'='Mozilla/5.0'} -Uri $u -OutFile $o -ErrorAction Stop;break}catch{if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429){$ra=$_.Exception.Response.GetResponseHeader('Retry-After');$s=0;if([int]::TryParse($ra,[ref]$s)){Start-Sleep -Seconds $s}else{Start-Sleep -Seconds ([int][math]::Pow(2,$i))}}else{throw}}};if(Test-Path $o){& $o}}"
'@
  Write-Host ($ps) -ForegroundColor DarkGray
  Write-Host ($cmd) -ForegroundColor DarkGray
}

Show-GitHub429-Tips

Write-Host ''
Write-Info 'Concluido. Reabra o terminal apos aplicar os comandos sugeridos.'
