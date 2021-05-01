from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


class TestPyenvFeatureGlobal(TestPyenvBase):
    def test_help(self, setup):
        def commands(ctx):
            stdout = "\r\n".join(ctx.pyenv("help").splitlines()[:2])
            assert stdout.strip() == "Usage: pyenv <command> [<args>]"
        run_pyenv_test({}, commands)
