from test_pyenv import TestPyenvBase
from test_pyenv_helpers import not_installed_output, run_pyenv_test


def pyenv_global_help():
    return (f"Usage: pyenv global <version>\r\n"
            f"       pyenv global --unset")


class TestPyenvFeatureGlobal(TestPyenvBase):
    def test_global_help(self, setup):
        def commands(ctx):
            for args in [
                ["--help", "global"],
                ["help", "global"],
                ["global", "--help"],
            ]:
                stdout, stderr = ctx.pyenv(args)
                assert ("\r\n".join(stdout.splitlines()[:2]), stderr) == (pyenv_global_help(), "")
        run_pyenv_test({}, commands)

    def test_global_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("global") == ("no global version configured", "")
        run_pyenv_test({}, commands)

    def test_global_version_defined(self, setup):
        def commands(ctx):
            assert ctx.pyenv("global") == ("3.8.9", "")
        run_pyenv_test({'global_ver': "3.8.9"}, commands)

    def test_global_set_installed_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["global", "3.7.7"]) == ("", "")
            assert ctx.pyenv("global") == ("3.7.7", "")
        settings = {
            'versions': ["3.7.7", "3.8.9"],
            'global_ver': "3.8.9"
        }
        run_pyenv_test(settings, commands)

    def test_global_set_unknown_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["global", "3.7.8"]) == (not_installed_output("3.7.8"), "")
        settings = {
            'versions': ["3.8.9"],
            'global_ver': "3.8.9",
        }
        run_pyenv_test(settings, commands)

    def test_global_unset(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["global", "--unset"]) == ("", "")
            assert ctx.pyenv("global") == ("no global version configured", "")
        settings = {
            'versions': ["3.8.9"],
            'global_ver': "3.8.9",
        }
        run_pyenv_test(settings, commands)

