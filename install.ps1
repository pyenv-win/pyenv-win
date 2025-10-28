param()
$ErrorActionPreference = 'Stop'
$url = 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1'
$dst = Join-Path $env:TEMP 'install-pyenv-win.ps1'

$retries = 5
for($i=1;$i -le $retries;$i++){
  try {
    Invoke-WebRequest -UseBasicParsing -Headers @{ 'User-Agent'='Mozilla/5.0' } -Uri $url -OutFile $dst -ErrorAction Stop
    break
  } catch {
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
      $ra = $_.Exception.Response.GetResponseHeader('Retry-After')
      if ([int]::TryParse($ra,[ref]$s)) { Start-Sleep -Seconds $s }
      else { Start-Sleep -Seconds ([int][math]::Pow(2,$i)) }
    } else { throw }
  }
}

if (Test-Path $dst) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $dst
} else {
  throw "Download failed: $url"
}
