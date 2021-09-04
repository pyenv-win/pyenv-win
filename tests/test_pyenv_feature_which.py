from tempenv import TemporaryEnvironment
from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


def assert_paths_equal(actual, expected):
    assert actual.lower() == expected.lower()


def pyenv_which_usage():
    return (f"Usage: pyenv which <command>\r\n"
            f"\r\n"
            f"Shows the full path of the executable\r\n"
            f"selected. To obtain the full path, use `pyenv which pip'.")


class TestPyenvFeatureWhich(TestPyenvBase):
    def test_which_no_arg(self, setup):
        def commands(ctx):
            assert ctx.pyenv("which") == (pyenv_which_usage(), "")
            assert ctx.pyenv(["which", "--help"]) == (pyenv_which_usage(), "")
            assert ctx.pyenv(["--help", "which"]) == (pyenv_which_usage(), "")
            assert ctx.pyenv(["help", "which"]) == (pyenv_which_usage(), "")
        run_pyenv_test({'versions': ['3.7.7']}, commands)

    def test_which_exists_is_global(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                sub_dir = '' if 'python' in name else 'Scripts\\'
                stdout, stderr = ctx.pyenv(["which", name])
                assert_paths_equal(stdout, rf'{ctx.pyenv_path}\versions\3.8.5\{sub_dir}{name}.exe')
                assert stderr == ""
        settings = {
            'versions': ['3.8.5'],
            'global_ver': '3.8.5'
        }
        run_pyenv_test(settings, commands)

    def test_which_exists_is_local(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                sub_dir = '' if 'python' in name else 'Scripts\\'
                stdout, stderr = ctx.pyenv(["which", name])
                assert_paths_equal(stdout, rf'{ctx.pyenv_path}\versions\3.8.5\{sub_dir}{name}.exe')
                assert stderr == ""
        settings = {
            'versions': ['3.8.5'],
            'local_ver': '3.8.5'
        }
        run_pyenv_test(settings, commands)

    def test_which_exists_is_shell(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                sub_dir = '' if 'python' in name else 'Scripts\\'
                stdout, stderr = ctx.pyenv(["which", name])
                assert_paths_equal(stdout, rf'{ctx.pyenv_path}\versions\3.8.5\{sub_dir}{name}.exe')
                assert stderr == ""
        with TemporaryEnvironment({"PYENV_VERSION": "3.8.5"}):
            run_pyenv_test({'versions': ['3.8.5']}, commands)

    def test_which_exists_is_global_not_installed(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == ("pyenv: version `3.8.5' is not installed (set by 3.8.5)", "")
        run_pyenv_test({'global_ver': '3.8.5'}, commands)

    def test_which_exists_is_local_not_installed(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == ("pyenv: version `3.8.5' is not installed (set by 3.8.5)", "")
        run_pyenv_test({'local_ver': '3.8.5'}, commands)

    def test_which_exists_is_shell_not_installed(self, setup):
        def commands(ctx):
            for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == ("pyenv: version `3.8.5' is not installed (set by 3.8.5)", "")
        with TemporaryEnvironment({"PYENV_VERSION": "3.8.5"}):
            run_pyenv_test({}, commands)

    def test_which_exists_is_global_other_version(self, setup):
        def commands(ctx):
            for name in ['python38', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == (
                    (
                        f"pyenv: {name}: command not found\r\n"
                        f"\r\n"
                        f"The '{name}' command exists in these Python versions:\r\n"
                        f"  3.8.2\r\n"
                        f"  3.8.6\r\n"
                        f"  "
                    ),
                    ""
                )
        settings = {
            'versions': ['3.8.2', '3.8.6', '3.9.1'],
            'global_ver': '3.9.1'
        }
        run_pyenv_test(settings, commands)

    def test_which_exists_is_local_other_version(self, setup):
        def commands(ctx):
            for name in ['python38', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == (
                    (
                        f"pyenv: {name}: command not found\r\n"
                        f"\r\n"
                        f"The '{name}' command exists in these Python versions:\r\n"
                        f"  3.8.2\r\n"
                        f"  3.8.6\r\n"
                        f"  "
                    ),
                    ""
                )
        settings = {
            'versions': ['3.8.2', '3.8.6', '3.9.1'],
            'local_ver': '3.9.1'
        }
        run_pyenv_test(settings, commands)

    def test_which_exists_is_shell_other_version(self, setup):
        def commands(ctx):
            for name in ['python38', 'python3.8', 'pip3.8']:
                assert ctx.pyenv(["which", name]) == (
                    (
                        f"pyenv: {name}: command not found\r\n"
                        f"\r\n"
                        f"The '{name}' command exists in these Python versions:\r\n"
                        f"  3.8.2\r\n"
                        f"  3.8.6\r\n"
                        f"  "
                    ),
                    ""
                )
        settings = {
            'versions': ['3.8.2', '3.8.6', '3.9.1'],
        }
        with TemporaryEnvironment({"PYENV_VERSION": "3.9.1"}):
            run_pyenv_test(settings, commands)

    def test_which_command_not_found(self, setup):
        def commands(ctx):
            for name in ['unknown3.8']:
                assert ctx.pyenv(["which", name]) == (f"pyenv: {name}: command not found", "")
        settings = {
            'versions': ['3.8.6'],
            'global_ver': '3.8.6'
        }
        run_pyenv_test(settings, commands)

    def test_which_no_version_defined(self, setup):
        def commands(ctx):
            for name in ['python']:
                assert ctx.pyenv(["which", name]) == (
                    (
                        "No global python version has been set yet. "
                        "Please set the global version by typing:\r\n"
                        "pyenv global 3.7.2"
                    ),
                    ""
                )
        run_pyenv_test({'versions': ['3.8.6']}, commands)

    def test_which_many_local_versions(self, setup):
        def commands(ctx):
            cases = [
                ('python37', r'3.7.7\python37.exe'),
                ('python38', r'3.8.2\python38.exe'),
                ('pip3.7', r'3.7.7\Scripts\pip3.7.exe'),
                ('pip3.8', r'3.8.2\Scripts\pip3.8.exe'),
            ]
            for (name, path) in cases:
                stdout, stderr = ctx.pyenv(["which", name])
                assert_paths_equal(stdout, rf'{ctx.pyenv_path}\versions\{path}')
                assert stderr == ""
        settings = {
            'versions': ['3.7.7', '3.8.2', '3.9.1'],
            'local_ver': '3.7.7\n3.8.2\n'
        }
        run_pyenv_test(settings, commands)
