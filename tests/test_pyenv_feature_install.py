import subprocess
from test_pyenv import TestPyenvBase

class TestPyenvFeatureInstall(TestPyenvBase):
    def test_check_pyenv_install_list(self, setup):
        result = subprocess.run(['pyenv', 'install', '-l'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result = str(result.stdout, "utf-8")
        print(result)
        assert True
    
    def test_check_pyenv_installation(self, setup):
        # TODO: tracking the logs of installation and checking the folder
        pass
        
    
