import subprocess
import tempfile
from contextlib import contextmanager
from pathlib import Path
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import install_pyenv, working_directory


@contextmanager
def temp_pyenv_for_versions(versions=None):
    if versions is None:
        versions = []
    with tempfile.TemporaryDirectory() as tmp_path:
        install_pyenv(tmp_path, versions)
        with working_directory(tmp_path):
            bat = Path(tmp_path, r'bin\pyenv.bat')
            args = ['cmd', '/d', '/c', f'call {bat}', 'versions']
            result = subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            result = str(result.stdout, "utf-8").strip()
            yield result


class TestPyenvFeatureVersions(TestPyenvBase):
    def test_list_no_version(self, setup):
        with temp_pyenv_for_versions() as output:
            assert output == ""

    def test_list_all_versions(self, setup):
        versions = ['3.7.7', '3.8.7']
        with temp_pyenv_for_versions(versions) as output:
            for v in versions:
                assert v in output
