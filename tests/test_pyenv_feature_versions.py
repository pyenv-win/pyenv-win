from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


class TestPyenvFeatureVersions(TestPyenvBase):
    def test_list_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == ("", "")
        run_pyenv_test({}, commands)

    def test_list_all_versions(self, setup):
        def commands(ctx):
            stdout, stderr = ctx.pyenv("versions")
            for v in versions:
                assert v in stdout
            assert stderr == ""
        versions = ['3.7.4', '3.8.5']
        run_pyenv_test({'versions': versions}, commands)

    def test_list_current_global_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"  3.6.5\r\n"
                    f"* 3.7.7 (set by {ctx.pyenv_path}\\version)\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.7"
        }
        run_pyenv_test(settings, commands)

    def test_list_current_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"* 3.6.5 (set by {ctx.local_path}\\.python-version)\r\n"
                    f"  3.7.7\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.7",
            'local_ver': "3.6.5"
        }
        run_pyenv_test(settings, commands)

    def test_list_current_local_many_versions(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"* 3.6.5 (set by {ctx.local_path}\\.python-version)\r\n"
                    f"* 3.7.7 (set by {ctx.local_path}\\.python-version)\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.9.1",
            'local_ver': "3.6.5\n3.7.7\n"
        }
        run_pyenv_test(settings, commands)

    def test_list_current_shell_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"  3.6.5\r\n"
                    f"  3.7.7\r\n"
                    f"* 3.9.1 (set by %PYENV_VERSION%)"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.7",
            'local_ver': "3.6.5"
        }
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.1"}):
            run_pyenv_test(settings, commands)

    def test_list_uninstalled_current_global_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"  3.6.5\r\n"
                    f"  3.7.7\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.5"
        }
        run_pyenv_test(settings, commands)

    def test_list_uninstalled_local_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"  3.6.5\r\n"
                    f"  3.7.7\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.7",
            'local_ver': "3.6.1"
        }
        run_pyenv_test(settings, commands)

    def test_list_uninstalled_shell_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == (
                (
                    f"  3.6.5\r\n"
                    f"  3.7.7\r\n"
                    f"  3.9.1"
                ),
                ""
            )
        settings = {
            'versions': ["3.6.5", "3.7.7", "3.9.1"],
            'global_ver': "3.7.7",
            'local_ver': "3.6.5"
        }
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.2"}):
            run_pyenv_test(settings, commands)
