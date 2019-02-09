@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :install: test
call pyenv install -l
call pyenv install 3.5.2
call pyenv install 2.7.15
call pyenv install 3.7.2


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
@echo off
setlocal

set PATH=%~dp0..\bin;%~dp0..\shims;%PATH%

echo :install: test
call rbenv install -l
call rbenv install 2.1.8
call rbenv install 2.1.7-x64
call rbenv install 1.9.3-p551


mkdir test
cd test
echo :global: test
call rbenv global 2.1.8
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

echo :local: test
call rbenv local 2.1.7-x64
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions
cd ..
call ruby -v
call rbenv version
call rbenv versions
cd test
call ruby -v
call rbenv version
call rbenv versions

echo :shell: test
call rbenv shell 1.9.3-p551
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions
cd ..
call ruby -v
call rbenv version
call rbenv versions
cd test
call ruby -v
call rbenv version
call rbenv versions

echo :shell --unset: test
call rbenv shell --unset
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

echo :local --unset: test
call rbenv local --unset
call rbenv rehash
call ruby -v
call rbenv version
call rbenv versions

cd ..
rmdir /s /q test

