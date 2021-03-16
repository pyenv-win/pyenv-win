@echo off
setlocal enableDelayedExpansion
chcp 1250 >nul

IF EXIST "%~dp0"..\exec.bat (
   del /F /Q "%~dp0"..\exec.bat >nul
)

call cscript //nologo "%~dp0"..\libexec\pyenv.vbs %*
IF EXIST "%~dp0"..\exec.bat (
   call "%~dp0"..\exec.bat
)
for /f "tokens=1 delims=|" %%A in (""!PYENV_VERSION!"") do (
   endLocal
   set "PYENV_VERSION=%%~A"
)
