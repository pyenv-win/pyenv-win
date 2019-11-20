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

    def test_pyenv_env_path(self, setup):
        assert setup.exists() is True
        assert str(setup) in sys.path
    
    # def test_pyenv_version(self, setup):
    #     ver_path = str(setup.parent.parent / '.version')
    #     version = open(ver_path).read()
    #     result = subprocess.run(['pyenv', '--version'], capture_output=True, shell=True)
    #     print(":: Result :: {}".format(result))
    #     print(":: Version :: {}".format(version))
    #     assert version in str(result.stdout, "utf-8")
    
    # def test_pyenv_features(self, setup):
    #     result = subprocess.run(['pyenv'], capture_output=True, shell=True)
    #     print(":: Result :: {}".format(result))
    #     result = str(result.stdout, "utf-8")
    #     assert 'install' in result
    # pass