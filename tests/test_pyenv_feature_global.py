import subprocess
import tempfile
from pathlib import Path
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import install_pyenv, temp_pyenv, working_directory


class TestPyenvFeatureGlobal(TestPyenvBase):
    def test_no_global_version(self, setup):
        with temp_pyenv("global") as output:
            assert output == "no global version configured"

    def test_global_version_defined(self, setup):
        with temp_pyenv("global", global_ver="3.8.9") as output:
            assert output == "3.8.9"

    def test_global_set_installed_version(self, setup):
        with tempfile.TemporaryDirectory() as tmp_path:
            install_pyenv(tmp_path, ["3.7.7", "3.8.9"], "3.8.9")
            with working_directory(tmp_path):
                bat = Path(tmp_path, r'bin\pyenv.bat')

                def pyenv_global(option=None):
                    args = ['cmd', '/d', '/c', f'call {bat}', "global"]
                    if option is not None:
                        args.append(option)
                    result = subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    output = str(result.stdout, "utf-8").strip()
                    return output

                assert pyenv_global("3.7.7") == ""
                assert pyenv_global() == "3.7.7"

    def test_global_set_unknown_version(self, setup):
        with temp_pyenv("global", "3.7.8", ["3.8.9"], "3.8.9") as output:
            assert output == ("pyenv specific python requisite didn't meet. "
                              "Project is using different version of python.\r\n"
                              "Install python '3.7.8' by typing: 'pyenv install 3.7.8'")

    def test_global_unset(self, setup):
        with tempfile.TemporaryDirectory() as tmp_path:
            install_pyenv(tmp_path, ["3.8.9"], "3.8.9")
            with working_directory(tmp_path):
                bat = Path(tmp_path, r'bin\pyenv.bat')

                def pyenv_global(option=None):
                    args = ['cmd', '/d', '/c', f'call {bat}', "global"]
                    if option is not None:
                        args.append(option)
                    result = subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    output = str(result.stdout, "utf-8").strip()
                    return output

                assert pyenv_global("--unset") == ""
                assert pyenv_global() == "no global version configured"
