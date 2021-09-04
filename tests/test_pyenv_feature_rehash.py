from packaging import version
from pathlib import Path
from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import python_exes, script_exes, run_pyenv_test


def assert_shims(pyenv_path, ver):
    shims_path = Path(pyenv_path, 'shims')
    ver = version.parse(ver)
    suffixes = [f'{ver.major}', f'{ver.major}{ver.minor}', f'{ver.major}.{ver.minor}']
    all_exes = [Path(n).stem for n in list(python_exes(suffixes)) + list(script_exes(ver))]
    all_shims = [n + s for n in all_exes for s in ['', '.bat']]
    for s in all_shims:
        assert shims_path.joinpath(s).is_file()


class TestPyenvFeatureRehash(TestPyenvBase):
    def test_rehash_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv('rehash') == (
                "No version installed. Please install one with 'pyenv install <version>'.",
                ""
            )
        run_pyenv_test({}, commands)

    def test_rehash_global_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv('rehash') == ("", "")
            assert_shims(ctx.pyenv_path, '3.8.6')
            assert_shims(ctx.pyenv_path, '3.8.7')
        settings = {
            'versions': ['3.8.6', '3.8.7'],
            'global_ver': '3.8.6',
        }
        run_pyenv_test(settings, commands)

    def test_rehash_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv('rehash') == ("", "")
            assert_shims(ctx.pyenv_path, '3.8.6')
            assert_shims(ctx.pyenv_path, '3.9.1')
        settings = {
            'versions': ['3.8.6', '3.9.1'],
            'global_ver': '3.8.6',
            'local_ver': '3.9.1'
        }
        run_pyenv_test(settings, commands)

    def test_rehash_shell_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv('rehash') == ("", "")
        global_ver = '3.7.5'
        local_ver = '3.8.6'
        shell_ver = '3.9.1'
        settings = {
            'versions': [global_ver, local_ver, shell_ver],
            'global_ver': global_ver,
            'local_ver': local_ver
        }
        with TemporaryEnvironment({"PYENV_VERSION": shell_ver}):
            run_pyenv_test(settings, commands)
