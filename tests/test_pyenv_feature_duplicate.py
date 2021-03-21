import subprocess
from test_pyenv import TestPyenvBase


class TestPyenvFeatureDuplicate(TestPyenvBase):
    def test_check_pyenv_duplicate(self, setup):
        # TODO: assert the list of commands
        result = subprocess.run(['pyenv'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result = str(result.stdout, "utf-8")
        pass

    def test_check_pyenv_commands_help(self, setup):
        # TODO: assert the help result
        pass

