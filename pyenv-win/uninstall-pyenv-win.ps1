param(
  [ValidateSet('KeepVersions','Full')]
  [string]$Mode = 'KeepVersions',
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host $msg -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host $msg -ForegroundColor Red }

$UserRoot = Join-Path $env:USERPROFILE ".pyenv\pyenv-win"
$Bin = Join-Path $UserRoot 'bin'
$Shims = Join-Path $UserRoot 'shims'
$PathsToRemove = @($Bin, $Shims)

function Check-MachinePathForPyenv {
  $mp = [Environment]::GetEnvironmentVariable('Path','Machine')
  if ($mp -and ($mp -match "\\\.pyenv\\pyenv-win\\(bin|shims)")) {
    Write-Err "Pyenv foi encontrado no PATH do sistema (Maquina). Isso e proibido. Remova do PATH do sistema antes de continuar."
    Write-Info "Sugestao (PowerShell Admin):"
    Write-Host "  `$mp = [Environment]::GetEnvironmentVariable('Path','Machine')"
    Write-Host "  `$mp = (`$mp -split ';' | Where-Object { `$_ -notmatch '\\.pyenv\\pyenv-win\\(bin|shims)' }) -join ';'"
    Write-Host "  [Environment]::SetEnvironmentVariable('Path',`$mp,'Machine')"
    throw "Machine PATH contem pyenv"
  }
}

function Remove-FromUserPath {
  $up = [Environment]::GetEnvironmentVariable('Path','User')
  if (-not $up) { return $false }
  $parts = $up -split ';' | Where-Object { $_ -ne '' }
  $filtered = @()
  foreach ($p in $parts) {
    $pp = $p.Trim()
    if ($pp -match "\\\.pyenv\\pyenv-win\\(bin|shims)") { continue }
    $filtered += $pp
  }
  $new = ($filtered -join ';')
  if ($new -ne $up) {
    if ($WhatIf) { Write-Warn '[WhatIf] Nao alterado: remover entradas do pyenv no PATH do Usuario' }
    else {
      [Environment]::SetEnvironmentVariable('Path',$new,'User')
      Write-Info 'Removido pyenv do PATH do Usuario.'
    }
    return $true
  }
  return $false
}

function Remove-ProfileLines {
  $profile = $PROFILE
  if (-not (Test-Path $profile)) { Write-Info 'Perfil do PowerShell nao encontrado.'; return }
  $lines = Get-Content -Path $profile -ErrorAction SilentlyContinue
  if (-not $lines) { return }
  $kept = @()
  $removed = 0
  foreach($l in $lines){
    if ($l -match '\\\.pyenv\\pyenv-win' -or $l -match 'PYENV_ROOT' -or $l -match 'pyenv-win\\\\(bin|shims)') { $removed++ ; continue }
    $kept += $l
  }
  if ($removed -gt 0) {
    if ($WhatIf) { Write-Warn "[WhatIf] Nao alterado: remover $removed linha(s) do perfil $profile" }
    else {
      Set-Content -Path $profile -Value ($kept -join "`r`n") -Encoding UTF8
      Write-Info "Removidas $removed linha(s) relacionadas ao pyenv do perfil."
    }
  } else {
    Write-Info 'Nenhuma linha do pyenv encontrada no perfil.'
  }
}

function Clear-UserEnvVars {
  if ($WhatIf) { Write-Warn '[WhatIf] Nao alterado: limpar variaveis de ambiente do Usuario (PYENV, PYENV_ROOT)' }
  else {
    [Environment]::SetEnvironmentVariable('PYENV',$null,'User')
    [Environment]::SetEnvironmentVariable('PYENV_ROOT',$null,'User')
    Write-Info 'Limpas variaveis de ambiente do Usuario: PYENV, PYENV_ROOT.'
  }
}

function Remove-Files {
  if ($Mode -eq 'Full') {
    if (-not (Test-Path $UserRoot)) { Write-Info "Nada para remover em $UserRoot"; return }
    if ($WhatIf) { Write-Warn "[WhatIf] Nao removido: $UserRoot" }
    else {
      Remove-Item -LiteralPath $UserRoot -Recurse -Force -ErrorAction SilentlyContinue
      Write-Info "Removido: $UserRoot (todas as versoes e caches)."
    }
  } else {
    Write-Info 'Modo KeepVersions: nenhuma pasta removida.'
  }
}

Write-Info "pyenv-win Uninstaller"
Write-Info "Modo: $Mode"

Check-MachinePathForPyenv
$changed = Remove-FromUserPath
Remove-ProfileLines
Clear-UserEnvVars
Remove-Files

Write-Host ''
Write-Info 'Concluido.'
if ($changed -and -not $WhatIf) {
  Write-Info 'Feche e reabra o terminal (ou execute:  . $PROFILE ) para refletir o PATH.'
}
