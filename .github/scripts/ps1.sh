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
