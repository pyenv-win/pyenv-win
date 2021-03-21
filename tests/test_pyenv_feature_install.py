import subprocess
from test_pyenv import TestPyenvBase


class TestPyenvFeatureInstall(TestPyenvBase):
    def test_check_pyenv_install_list(self, setup):
        result = subprocess.run(['pyenv', 'install', '-l'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result = str(result.stdout, "utf-8")
        assert "Mirror: https://www.python.org/ftp/python" in result
        assert "2.7.17-win32" in result
        assert "2.7.17" in result
        assert "3.1.4-win32" in result
        assert "3.1.4" in result
        assert "3.2.5-win32" in result
        assert "3.2.5" in result
        assert "3.3.5-win32" in result
        assert "3.3.5" in result
        assert "3.4.4-win32" in result
        assert "3.4.4" in result
        assert "3.5.4-win32" in result
        assert "3.5.4" in result
        assert "3.6.8-win32" in result
        assert "3.6.8" in result
        assert "3.7.7-win32" in result
        assert "3.7.7" in result
        assert "3.8.2-win32" in result
        assert "3.8.2" in result
        assert "3.9.0-win32" in result
        assert "3.9.0" in result
        assert "3.9.1-win32" in result
        assert "3.9.1" in result
    
    def test_check_pyenv_installation(self, setup):
        # TODO: tracking the logs of installation and checking the folder
        pass

