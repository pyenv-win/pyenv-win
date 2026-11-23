@echo off
setlocal enabledelayedexpansion

set WIX_BIN="C:\Program Files (x86)\WiX Toolset v3.14\bin"
set WIXUI=%WIX_BIN%\WixUIExtension.dll

set OUTPUT_DIR=build

echo === Building pyenv-win MSI installer ===
echo.

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo [1/2] Compiling WiX source...
"%WIX_BIN%\candle.exe" -nologo -arch x64 -out "%OUTPUT_DIR%\pyenv-win.wixobj" pyenv-win.wxs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo [2/2] Linking MSI...
"%WIX_BIN%\light.exe" -nologo -ext "%WIXUI%" -cultures:en-us -out "%OUTPUT_DIR%\pyenv-win.msi" "%OUTPUT_DIR%\pyenv-win.wixobj"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo.
echo === Success! MSI created: %OUTPUT_DIR%\pyenv-win.msi ===
endlocal
