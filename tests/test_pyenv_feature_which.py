import pytest

from test_pyenv_helpers import Native


def assert_paths_equal(actual, expected):
    assert actual.lower() == expected.lower()


def pyenv_which_usage():
    return (f"Usage: pyenv which <command>\r\n"
            f"\r\n"
            f"Shows the full path of the executable\r\n"
            f"selected. To obtain the full path, use `pyenv which pip'.")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native('3.7.7')]}])
def test_which_no_arg(pyenv):
    assert pyenv.which() == (pyenv_which_usage(), "")
    assert pyenv.which("--help") == (pyenv_which_usage(), "")
    assert pyenv("--help", "which") == (pyenv_which_usage(), "")
    assert pyenv("help", "which") == (pyenv_which_usage(), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.5')],
        'global_ver': Native('3.8.5')
    }])
def test_which_exists_is_global(pyenv_path, pyenv):
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        sub_dir = '' if 'python' in name else 'Scripts\\'
        stdout, stderr = pyenv.which(name)
        assert_paths_equal(stdout, rf'{pyenv_path}\versions\{Native("3.8.5")}\{sub_dir}{name}.exe')
        assert stderr == ""


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.5')],
        'local_ver': Native('3.8.5')
    }])
def test_which_exists_is_local(pyenv_path, pyenv):
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        sub_dir = '' if 'python' in name else 'Scripts\\'
        stdout, stderr = pyenv.which(name)
        assert_paths_equal(stdout, rf'{pyenv_path}\versions\{Native("3.8.5")}\{sub_dir}{name}.exe')
        assert stderr == ""


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native('3.8.5')]}])
def test_which_exists_is_shell(pyenv_path, pyenv):
    env = {"PYENV_VERSION": Native("3.8.5")}
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        sub_dir = '' if 'python' in name else 'Scripts\\'
        stdout, stderr = pyenv.which(name, env=env)
        assert_paths_equal(stdout, rf'{pyenv_path}\versions\{Native("3.8.5")}\{sub_dir}{name}.exe')
        assert stderr == ""


@pytest.mark.parametrize('settings', [lambda: {'global_ver': Native('3.8.5')}])
def test_which_exists_is_global_not_installed(pyenv):
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        assert pyenv.which(name) == (f"pyenv: version '{Native('3.8.5')}' is not installed (set by {Native('3.8.5')})", "")


@pytest.mark.parametrize('settings', [lambda: {'local_ver': Native('3.8.5')}])
def test_which_exists_is_local_not_installed(pyenv):
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        assert pyenv.which(name) == (f"pyenv: version '{Native('3.8.5')}' is not installed (set by {Native('3.8.5')})", "")


def test_which_exists_is_shell_not_installed(pyenv):
    env = {"PYENV_VERSION": Native("3.8.5")}
    for name in ['python', 'python3', 'python38', 'pip3', 'pip3.8']:
        assert pyenv.which(name, env=env) == (f"pyenv: version '{Native('3.8.5')}' is not installed (set by {Native('3.8.5')})", "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.2'), Native('3.8.6'), Native('3.9.1')],
        'global_ver': Native('3.9.1')
    }])
def test_which_exists_is_global_other_version(pyenv):
    for name in ['python38', 'pip3.8']:
        assert pyenv.which(name) == (
            (
                f"pyenv: {name}: command not found\r\n"
                f"\r\n"
                f"The '{name}' command exists in these Python versions:\r\n"
                f"  {Native('3.8.2')}\r\n"
                f"  {Native('3.8.6')}\r\n"
                f"  "
            ),
            ""
        )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.2'), Native('3.8.6'), Native('3.9.1')],
        'local_ver': Native('3.9.1')
    }])
def test_which_exists_is_local_other_version(pyenv):
    for name in ['python38', 'pip3.8']:
        assert pyenv.which(name) == (
            (
                f"pyenv: {name}: command not found\r\n"
                f"\r\n"
                f"The '{name}' command exists in these Python versions:\r\n"
                f"  {Native('3.8.2')}\r\n"
                f"  {Native('3.8.6')}\r\n"
                f"  "
            ),
            ""
        )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.2'), Native('3.8.6'), Native('3.9.1')],
    }])
def test_which_exists_is_shell_other_version(pyenv):
    env = {"PYENV_VERSION": Native("3.9.1")}
    for name in ['python38', 'python3.8', 'pip3.8']:
        assert pyenv.which(name, env=env) == (
            (
                f"pyenv: {name}: command not found\r\n"
                f"\r\n"
                f"The '{name}' command exists in these Python versions:\r\n"
                f"  {Native('3.8.2')}\r\n"
                f"  {Native('3.8.6')}\r\n"
                f"  "
            ),
            ""
        )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.6')],
        'global_ver': Native('3.8.6')
    }])
def test_which_command_not_found(pyenv):
    for name in ['unknown3.8']:
        assert pyenv.which(name) == (f"pyenv: {name}: command not found", "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native('3.8.6')]}])
def test_which_no_version_defined(pyenv):
    for name in ['python']:
        assert pyenv.which(name) == (
            (
                "No global/local python version has been set yet. "
                "Please set the global/local version by typing:\r\n"
                "pyenv global <python-version>\r\n"
                "pyenv global 3.7.4\r\n"
                "pyenv local <python-version>\r\n"
                "pyenv local 3.7.4"
            ),
            ""
        )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.7.7'), Native('3.8.2'), Native('3.9.1')],
        'local_ver': [Native('3.7.7'), Native('3.8.2')]
    }])
def test_which_many_local_versions(pyenv_path, pyenv):
    cases = [
        ('python37', rf'{Native("3.7.7")}\python37.exe'),
        ('python38', rf'{Native("3.8.2")}\python38.exe'),
        ('pip3.7', rf'{Native("3.7.7")}\Scripts\pip3.7.exe'),
        ('pip3.8', rf'{Native("3.8.2")}\Scripts\pip3.8.exe'),
    ]
    for (name, path) in cases:
        stdout, stderr = pyenv.which(name)
        assert_paths_equal(stdout, rf'{pyenv_path}\versions\{path}')
        assert stderr == ""

