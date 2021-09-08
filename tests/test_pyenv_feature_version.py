import os
import tempfile
from pathlib import Path
from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test, touch


def pyenv_version_help():
    return "Usage: pyenv version"


class TestPyenvFeatureVersion(TestPyenvBase):
    def test_version_help(self, setup):
        def commands(ctx):
            for args in [
                ["--help", "version"],
                ["help", "version"],
                ["version", "--help"],
            ]:
                stdout, stderr = ctx.pyenv(args)
                assert ("\r\n".join(stdout.splitlines()[:2]).strip(), stderr) == (pyenv_version_help(), "")
        run_pyenv_test({}, commands)

    def test_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == (
                (
                    "No global python version has been set yet. "
                    "Please set the global version by typing:\r\n"
                    "pyenv global 3.7.2"
                ),
                ""
            )
        run_pyenv_test({}, commands)

    def test_global_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == (rf'3.7.2 (set by {ctx.pyenv_path}\version)', "")
        run_pyenv_test({'global_ver': "3.7.2"}, commands)

    def test_one_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == (rf'3.9.1 (set by {ctx.local_path}\.python-version)', "")
        settings = {
            'global_ver': "3.7.2",
            'local_ver': "3.9.1"
        }
        run_pyenv_test(settings, commands)

    def test_shell_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == ("3.9.2 (set by %PYENV_VERSION%)", "")
        settings = {
            'global_ver': "3.7.5",
            'local_ver': "3.8.6",
        }
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.2"}):
            run_pyenv_test(settings, commands)

    def test_many_local_versions(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == (
                (
                    f'3.8.8 (set by {ctx.local_path}\\.python-version)\r\n'
                    f'3.9.1 (set by {ctx.local_path}\\.python-version)'
                ),
                ""
            )
        settings = {
            'global_ver': "3.7.2",
            'local_ver': "3.8.8\n3.9.1\n"
        }
        run_pyenv_test(settings, commands)

    def test_bad_path(self, setup):
        def commands(ctx):
            touch(Path(ctx.local_path, 'python.exe'))
            with TemporaryEnvironment({"PATH": f"{ctx.local_path};{os.environ['PATH']}"}):
                touch(Path(ctx.pyenv_path, r'shims\python.bat'))
                stdout, stderr = ctx.pyenv("version")
                expected = (f'\x1b[91mFATAL: Found \x1b[95m{ctx.local_path}\\python.exe\x1b[91m version '
                            f'before pyenv in PATH.\x1b[0m\r\n'
                            f'\x1b[91mPlease remove \x1b[95m{ctx.local_path}\\\x1b[91m from '
                            f'PATH for pyenv to work properly.\x1b[0m\r\n'
                            f'3.7.2 (set by {ctx.pyenv_path}\\version)')
                # Fix 8.3 mismatch in GitHub actions
                stdout = stdout.replace('RUNNER~1', 'runneradmin')
                expected = expected.replace('RUNNER~1', 'runneradmin')
                assert (stdout, stderr) == (expected, "")

        run_pyenv_test({'global_ver': "3.7.2"}, commands)
