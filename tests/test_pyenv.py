import pytest
import sys
import subprocess
from pathlib import Path

class TestPyenv:

    @pytest.fixture
    def setup(self):
        pyenv_path = Path.cwd()
        bin_path = pyenv_path / 'pyenv-win' / 'bin'
        shims_path = pyenv_path / 'pyenv-win' / 'shims'
        sys.path.append(str(bin_path))
        sys.path.append(str(shims_path))
        yield bin_path

    def test_check_pyenv_path(self, setup):
        assert setup.exists() is True
        assert str(setup) in sys.path
    
    def test_check_pyenv_version(self, setup):
        ver_path = str(setup.parent.parent / '.version')
        version = open(ver_path).read().strip()
        result = subprocess.run(['pyenv'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(":: Result :: {}".format(result))
        print(":: Version :: {}".format(version))
        assert version in str(result.stdout, "utf-8")
    
    def test_check_pyenv_features_list(self, setup):
        result = subprocess.run(['pyenv'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(":: Result :: {}".format(result))
        result = str(result.stdout, "utf-8")
        assert 'commands' in result
        assert 'duplicate' in result
        assert 'local' in result
        assert 'global' in result
        assert 'shell' in result
        assert 'install' in result
        assert 'uninstall' in result
        assert 'rehash' in result
        assert 'version' in result
        assert 'versions' in result
        assert 'exec' in result
        assert 'which' in result
        assert 'whence' in result
