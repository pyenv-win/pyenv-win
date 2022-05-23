echo "HOME='/d/a/pyenv-win/pyenv-win'" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
echo "PYENV='$HOME/pyenv-win'" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
echo "PYENV_HOME='$HOME/pyenv-win'" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
echo "PYENV_ROOT='$HOME/pyenv-win'" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
echo "PATH='$PYENV/bin:$PYENV/shims:$PATH'" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append


pyenv --version
pyenv update
pyenv install -q 3.7.4
pyenv global 3.7.4
pyenv versions
python --version
pip install --user --upgrade pip
pip install -r $HOME/requirements_dev.txt
pyenv rehash
PYTHONPATH=. python -m pytest -v -s --cache-clear --cov=pyenv-win $HOME/tests
