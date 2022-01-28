@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :install: test
call pyenv install -l
call pyenv install 3.5.2
call pyenv rehash 3.5.2
call pyenv install 2.7.15
call pyenv rehash 2.7.15
call pyenv install 3.7.2
call pyenv rehash 3.7.2
call pyenv install 3.9.0
call pyenv rehash 3.9.0
call pyenv install 3.10.0
call pyenv rehash 3.10.0

mkdir test
cd test
echo :global: test
call pyenv global 3.5.2
call pyenv rehash
call python --version
call pyenv version
call pyenv versions

echo :local: test
call pyenv local 2.7.15
call pyenv rehash
call python --version
call pyenv version
call pyenv versions

cd ..
call python --version
call pyenv version
call pyenv versions

cd test
call python --version
call pyenv version
call pyenv versions

echo :shell: test
call pyenv shell 3.7.2
call pyenv rehash
call python --version
call pyenv version
call pyenv versions
cd ..
call python --version
call pyenv version
call pyenv versions
cd test
call python --version
call pyenv version
call pyenv versions

echo :shell --unset: test
call pyenv shell --unset
call pyenv rehash
call python --version
call pyenv version
call pyenv versions

echo :local --unset: test
call pyenv local --unset
call pyenv rehash
call python --version
call pyenv version
call pyenv versions

cd ..
rmdir /s /q test

