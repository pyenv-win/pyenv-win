$null = @'
<#
.SYNOPSIS
  Interactive pyenv-win uninstaller (single-flow).

.DESCRIPTION
  - Always asks for confirmation and removes %USERPROFILE%\.pyenv\pyenv-win (pyenv + versions + cache).
  - Does NOT change PATH or shell profiles automatically.

.USAGE
  - From pyenv:  pyenv remove
  - Direct PowerShell:  & '.\\pyenv-win\\uninstall-pyenv-win.ps1'

.NOTES
  - HTTP 429 (Too Many Requests) is GitHub's responsibility.
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

function Show-Manual-Remediation { }

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
  if (-not (Test-Path $UserRoot)) { Write-Info "Nothing to remove at $UserRoot"; return }
  if ($Mode -eq 'Full') {
    Remove-Item -LiteralPath $UserRoot -Recurse -Force -ErrorAction SilentlyContinue
    Write-Info "Removed: $UserRoot (pyenv + versions)."
  } else {
    # KeepVersions: remover tudo exceto 'versions'
    $items = Get-ChildItem -LiteralPath $UserRoot -Force -ErrorAction SilentlyContinue
    foreach ($it in $items) {
      if ($it.Name -ieq 'versions') { continue }
      Remove-Item -LiteralPath $it.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Info "Removed pyenv components; kept: $($UserRoot + '\\versions')"
  }
}

Write-Info "pyenv-win Uninstaller"

# Fluxo sempre interativo (sem chaves/flags)
$Mode = 'Full'

# 1) Confirm
$ans = Prompt-Confirm 'Confirm uninstall of pyenv-win?'
if ($ans -eq 'N') { Write-Info 'Cancelled by user.'; exit 0 }

# 2) Scope: always full removal (pyenv + all Python versions)
Write-Info 'Full removal: pyenv + all installed Python versions.'

# 3) Remover arquivos conforme escopo
Remove-Files

# 4) Do not change PATH/profile automatically.

Write-Info 'Note: HTTP 429 (Too Many Requests) is GitHub responsibility.'

Write-Host ''
Write-Info 'Done. Close and reopen the terminal.'
