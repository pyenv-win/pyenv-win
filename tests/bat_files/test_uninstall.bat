@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :uninstall: test
call pyenv versions
call pyenv uninstall 3.5.2
call pyenv uninstall --msi 2.7.15
call pyenv uninstall 3.7.2
call pyenv uninstall 3.9.0
call pyenv uninstall 3.10.0

