param()
$ErrorActionPreference = 'Stop'
$url = 'https://raw.githubusercontent.com/mauriciomenon/pyenv-win_adaptado/master/pyenv-win/install-pyenv-win.ps1'
$dst = Join-Path $env:TEMP 'install-pyenv-win.ps1'
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $dst
& powershell -NoProfile -ExecutionPolicy Bypass -File $dst
