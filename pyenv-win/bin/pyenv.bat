@echo off
setlocal
chcp 1250 >nul

IF EXIST "%~dp0"..\exec.bat (
   del /F /Q "%~dp0"..\exec.bat >nul
)

call cscript //nologo "%~dp0"..\libexec\pyenv.vbs %*
IF EXIST "%~dp0"..\exec.bat (
   "%~dp0"..\exec.bat
)
