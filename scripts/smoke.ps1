$ErrorActionPreference = 'Stop'

function ok($msg){ Write-Host "[OK]  $msg" -ForegroundColor Green }
function fail($msg){ Write-Host "[FAIL] $msg" -ForegroundColor Red; exit 1 }

$root = Join-Path $env:USERPROFILE '.pyenv\pyenv-win'
if (-not (Test-Path $root)) { fail "pyenv root missing at $root" }
if (-not (Test-Path (Join-Path $root 'bin'))) { fail 'bin missing' } else { ok 'bin exists' }
if (-not (Test-Path (Join-Path $root 'shims'))) { fail 'shims missing' } else { ok 'shims exists' }
if (-not (Test-Path (Join-Path $root 'versions'))) { fail 'versions dir missing' } else { ok 'versions exists' }

& (Join-Path $root 'bin\pyenv.bat') --version | Out-Null
ok 'pyenv available'

& (Join-Path $root 'bin\pyenv.bat') install -s 3.11.9 | Out-Null
& (Join-Path $root 'bin\pyenv.bat') install -s 3.10.11 | Out-Null

& (Join-Path $root 'bin\pyenv.bat') global 3.11.9 | Out-Null
& (Join-Path $root 'bin\pyenv.bat') rehash | Out-Null
$pyv = (& python --version) 2>$null
if ($pyv -notmatch '3\.11\.9') { fail "python not 3.11.9 (got: $pyv)" } else { ok 'python 3.11.9 global' }

& (Join-Path $root 'bin\pyenv.bat') global 3.10.11 | Out-Null
& (Join-Path $root 'bin\pyenv.bat') rehash | Out-Null
$pyv = (& python --version) 2>$null
if ($pyv -notmatch '3\.10\.11') { fail "python not 3.10.11 (got: $pyv)" } else { ok 'python 3.10.11 global' }

# Local override test
$tmp = Join-Path $env:TEMP ('pyenv_local_' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
Set-Content -Path (Join-Path $tmp '.python-version') -Value '3.11.9'
Push-Location $tmp
& (Join-Path $root 'bin\pyenv.bat') vname | Out-Null
$pyv = (& python --version) 2>$null
Pop-Location
Remove-Item -Recurse -Force $tmp
if ($pyv -notmatch '3\.11\.9') { fail "local override not effective (got: $pyv)" } else { ok 'local override works (3.11.9)' }

ok 'smoke completed'

