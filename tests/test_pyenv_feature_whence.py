from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


def pyenv_whence_usage():
    return (f"Usage: pyenv whence [--path] <command>\r\n"
            f"\r\n"
            f"Shows the currently given executable contains path\r\n"
            f"selected. To obtain python version of executable, use `pyenv whence pip'.")


class TestPyenvFeatureWhence(TestPyenvBase):
    def test_whence_no_arg(self, setup):
        def commands(ctx):
            assert ctx.pyenv("whence") == (pyenv_whence_usage(), "")
            assert ctx.pyenv(["whence", "--help"]) == (pyenv_whence_usage(), "")
            assert ctx.pyenv(["--help", "whence"]) == (pyenv_whence_usage(), "")
            assert ctx.pyenv(["help", "whence"]) == (pyenv_whence_usage(), "")
        run_pyenv_test({'versions': ['3.7.7']}, commands)

    def test_whence_major(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'pip3']:
                assert ctx.pyenv(["whence", name]) == ('3.7.7\r\n3.8.2\r\n3.8.7\r\n3.9.1', "")
        run_pyenv_test({'versions': ['3.7.7', '3.8.2', '3.8.7', '3.9.1']}, commands)

    def test_whence_major_minor(self, setup):
        def commands(ctx):
            for name in ['python38', 'python3.8', 'pip3.8']:
                assert ctx.pyenv(["whence", name]) == ('3.8.2\r\n3.8.7', "")
        run_pyenv_test({'versions': ['3.7.7', '3.8.2', '3.8.7', '3.9.1']}, commands)

    def test_whence_not_found(self, setup):
        def commands(ctx):
            for name in ['unknown3.8']:
                assert ctx.pyenv(["whence", name]) == ("", "")
        run_pyenv_test({'versions': ['3.7.7', '3.8.2', '3.8.7', '3.9.1']}, commands)
