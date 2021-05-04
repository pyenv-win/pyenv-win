from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


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
                assert "\r\n".join(ctx.pyenv(args).splitlines()[:2]).strip() == pyenv_version_help()
        run_pyenv_test({}, commands)

    def test_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == ("No global python version has been set yet. "
                                            "Please set the global version by typing:\r\n"
                                            "pyenv global 3.7.2")
        run_pyenv_test({}, commands)

    def test_global_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == rf'3.7.2 (set by {ctx.pyenv_path}\version)'
        run_pyenv_test({'global_ver': "3.7.2"}, commands)

    def test_one_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == rf'3.9.1 (set by {ctx.local_path}\.python-version)'
        settings = {
            'global_ver': "3.7.2",
            'local_ver': "3.9.1"
        }
        run_pyenv_test(settings, commands)

    def test_shell_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == "3.9.2 (set by %PYENV_VERSION%)"
        settings = {
            'global_ver': "3.7.5",
            'local_ver': "3.8.6",
        }
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.2"}):
            run_pyenv_test(settings, commands)

    def test_many_local_versions(self, setup):
        def commands(ctx):
            assert ctx.pyenv("version") == (f'3.8.8 (set by {ctx.local_path}\\.python-version)\r\n'
                                            f'3.9.1 (set by {ctx.local_path}\\.python-version)')
        settings = {
            'global_ver': "3.7.2",
            'local_ver': "3.8.8\n3.9.1\n"
        }
        run_pyenv_test(settings, commands)
