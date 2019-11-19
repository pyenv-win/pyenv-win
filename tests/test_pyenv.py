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
    
    def test_pyenv_version(self, setup):
        ver_path = str(setup.parent.parent / '.version')
        version = open(ver_path).read()
        result = subprocess.run(['pyenv', '--version'], capture_output=True)
        error = str(result.stderr.decode("utf-8"))
        result = str(result.stdout.decode("utf-8"))

        if error:
            assert False
        assert version in result
    pass