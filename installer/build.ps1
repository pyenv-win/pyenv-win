$WixBin = "${env:ProgramFiles(x86)}\WiX Toolset v3.14\bin"
$OutputDir = "build"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "=== Building pyenv-win MSI installer ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Compiling WiX source..."
& "$WixBin\candle.exe" -nologo -arch x64 -out "$OutputDir\pyenv-win.wixobj" pyenv-win.wxs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[2/2] Linking MSI..."
& "$WixBin\light.exe" -nologo -ext "$WixBin\WixUIExtension.dll" -cultures:en-us -out "$OutputDir\pyenv-win.msi" "$OutputDir\pyenv-win.wixobj"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "=== Success! MSI created: $OutputDir\pyenv-win.msi ===" -ForegroundColor Green
