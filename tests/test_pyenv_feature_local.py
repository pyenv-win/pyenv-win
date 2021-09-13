from test_pyenv import TestPyenvBase
from test_pyenv_helpers import local_python_versions, not_installed_output, run_pyenv_test


class TestPyenvFeatureLocal(TestPyenvBase):
    def test_no_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("local") == ("no local version configured for this directory", "")
        run_pyenv_test({}, commands)

    def test_local_version_defined(self, setup):
        def commands(ctx):
            assert ctx.pyenv("local") == ("3.8.9", "")
        run_pyenv_test({'local_ver': "3.8.9"}, commands)

    def test_local_set_installed_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["local", "3.7.7"]) == ("", "")
            assert ctx.pyenv("local") == ("3.7.7", "")
        settings = {
            'versions': ["3.7.7", "3.8.9"],
            'local_ver': "3.8.9",
        }
        run_pyenv_test(settings, commands)

    def test_local_set_unknown_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["local", "3.7.8"]) == (not_installed_output("3.7.8"), "")
        run_pyenv_test({'versions': ["3.8.9"]}, commands)

    def test_local_set_many_versions(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["local", "3.7.7", "3.8.9"]) == ("", "")
            assert local_python_versions(ctx.local_path) == "3.7.7\n3.8.9"
        run_pyenv_test({'versions': ["3.7.7", "3.8.9"]}, commands)

    def test_local_set_many_versions_one_not_installed(self, setup):
        def commands(ctx):
            assert ctx.pyenv(["local", "3.7.7", "3.8.9"]) == (not_installed_output("3.8.9"), "")
        run_pyenv_test({'versions': ["3.7.7"]}, commands)

    def test_local_many_versions_defined(self, setup):
        def commands(ctx):
            assert ctx.pyenv("local") == ("3.7.7\r\n3.8.9", "")
        run_pyenv_test({'local_ver': "3.7.7\n3.8.9\n"}, commands)
