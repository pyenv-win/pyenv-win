import tempfile
import subprocess
from pathlib import Path
from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import install_pyenv, temp_pyenv, working_directory


class TestPyenvFeatureShell(TestPyenvBase):
    def test_no_shell_version(self, setup):
        with TemporaryEnvironment({"PYENV_VERSION": ""}):
            with temp_pyenv("shell") as output:
                assert output == "no shell-specific version configured"

    def test_shell_version_defined(self, setup):
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.2"}):
            with temp_pyenv("shell") as output:
                assert output == "3.9.2"

    def test_shell_set_installed_version(self, setup):
        with TemporaryEnvironment({"PYENV_VERSION": "3.8.9"}):
            with tempfile.TemporaryDirectory() as tmp_path:
                install_pyenv(tmp_path, ["3.7.7", "3.8.9"])
                with working_directory(tmp_path):
                    bat = Path(tmp_path, r'bin\pyenv.bat')

                    def pyenv_shell(option=None):
                        tmp = str(Path(tmp_path, "a.bat"))
                        with open(tmp, "w") as f:
                            print(f'@call {bat} shell 3.7.7 & call {bat} shell', file=f)
                        # must chain commands because var is lost when cmd ends
                        args = ['cmd', '/d', '/c', 'call', tmp]
                        if option is not None:
                            args.append(option)
                        result = subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        output = str(result.stdout, "utf-8").strip()
                        return output

                    assert pyenv_shell("3.7.7") == "3.7.7"

    def test_shell_set_unknown_version(self, setup):
        with temp_pyenv("shell", "3.7.8", ["3.8.9"]) as output:
            assert output == ("pyenv specific python requisite didn't meet. "
                              "Project is using different version of python.\r\n"
                              "Install python '3.7.8' by typing: 'pyenv install 3.7.8'")
