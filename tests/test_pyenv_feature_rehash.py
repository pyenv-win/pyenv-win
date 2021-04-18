import subprocess
import tempfile
from packaging import version
from pathlib import Path
from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import install_pyenv, python_exes, script_exes, temp_pyenv, working_directory


def set_local_version(path, ver):
    with open(Path(path, ".python-version"), "w") as f:
        print(ver, file=f)


def pyenv_rehash(pyenv_path):
    bat = Path(pyenv_path, r'bin\pyenv.bat')
    args = ['cmd', '/d', '/c', f'call {bat}', 'rehash']
    subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def assert_shims(pyenv_path, ver):
    shims_path = Path(pyenv_path, 'shims')
    ver = version.parse(ver)
    suffixes = [f'{ver.major}', f'{ver.major}{ver.minor}']
    all_exes = [Path(n).stem for n in list(python_exes(suffixes)) + list(script_exes(ver))]
    all_shims = [n + s for n in all_exes for s in ['', '.bat']]
    for s in all_shims:
        assert shims_path.joinpath(s).is_file()


class TestPyenvFeatureRehash(TestPyenvBase):
    def test_rehash_global_version(self, setup):
        with tempfile.TemporaryDirectory() as pyenv_path:
            install_pyenv(pyenv_path, versions=['3.8.6', '3.8.7'], global_ver='3.8.6')
            with working_directory(pyenv_path):
                pyenv_rehash(pyenv_path)
                assert_shims(pyenv_path, '3.8.6')
                assert_shims(pyenv_path, '3.8.7')

    def test_rehash_local_version(self, setup):
        with tempfile.TemporaryDirectory() as pyenv_path, tempfile.TemporaryDirectory() as cur_path:
            install_pyenv(pyenv_path, versions=['3.8.6', '3.9.1'], global_ver='3.8.6')
            with working_directory(cur_path):
                set_local_version(cur_path, '3.9.1')
                pyenv_rehash(pyenv_path)
                assert_shims(pyenv_path, '3.8.6')
                assert_shims(pyenv_path, '3.9.1')

    def test_rehash_shell_version(self, setup):
        with tempfile.TemporaryDirectory() as pyenv_path, tempfile.TemporaryDirectory() as cur_path:
            global_ver = '3.7.5'
            local_ver = '3.8.6'
            shell_ver = '3.9.1'
            install_pyenv(pyenv_path, versions=[global_ver, local_ver, shell_ver], global_ver=global_ver)
            with working_directory(cur_path):
                with TemporaryEnvironment({"PYENV_VERSION": shell_ver}):
                    set_local_version(cur_path, local_ver)
                    pyenv_rehash(pyenv_path)
                    assert_shims(pyenv_path, global_ver)
                    assert_shims(pyenv_path, local_ver)
                    assert_shims(pyenv_path, shell_ver)

