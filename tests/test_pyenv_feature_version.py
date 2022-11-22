import pytest

import os
from pathlib import Path
from test_pyenv_helpers import touch, Native


def pyenv_version_help():
    return "Usage: pyenv version"


def test_version_help(pyenv):
    for args in [
        ["--help", "version"],
        ["help", "version"],
        ["version", "--help"],
    ]:
        stdout, stderr = pyenv(*args)
        assert ("\r\n".join(stdout.splitlines()[:2]).strip(), stderr) == (pyenv_version_help(), "")


def test_no_version(pyenv):
    assert pyenv.version() == (
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
        'global_ver': Native("3.7.4")
    }])
def test_global_version(pyenv_path, pyenv):
    assert pyenv.version() == (rf'{Native("3.7.4")} (set by {pyenv_path}\version)', "")


@pytest.mark.parametrize('settings', [lambda: {
        'global_ver': Native("3.7.4"),
        'local_ver': Native("3.9.1")
    }])
def test_one_local_version(local_path, pyenv):
    assert pyenv.version() == (rf'{Native("3.9.1")} (set by {local_path}\.python-version)', "")


@pytest.mark.parametrize('settings', [lambda: {
        'global_ver': Native("3.7.5"),
        'local_ver': Native("3.8.6"),
    }])
def test_shell_version(pyenv):
    env = {"PYENV_VERSION": Native("3.9.2")}
    assert pyenv.version(env=env) == (f"{Native('3.9.2')} (set by %PYENV_VERSION%)", "")


@pytest.mark.parametrize('settings', [lambda: {
        'global_ver': Native("3.7.4"),
        'local_ver': [Native("3.8.8"), Native("3.9.1")]
    }])
def test_many_local_versions(local_path, pyenv):
    assert pyenv.version() == (
        (
            f'{Native("3.8.8")} (set by {local_path}\\.python-version)\r\n'
            f'{Native("3.9.1")} (set by {local_path}\\.python-version)'
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {'global_ver': Native("3.7.4")}])
def test_bad_path(local_path, pyenv_path, pyenv):
    touch(Path(local_path, 'python.exe'))
    touch(Path(pyenv_path, r'shims\python.bat'))
    env = {"PATH": f"{local_path};{os.environ['PATH']}"}
    stdout, stderr = pyenv.version(env=env)
    expected = (f'\x1b[91mFATAL: Found \x1b[95m{local_path}\\python.exe\x1b[91m version '
                f'before pyenv in PATH.\x1b[0m\r\n'
                f'\x1b[91mPlease remove \x1b[95m{local_path}\\\x1b[91m from '
                f'PATH for pyenv to work properly.\x1b[0m\r\n'
                f'{Native("3.7.4")} (set by {pyenv_path}\\version)')
    # Fix 8.3 mismatch in GitHub actions
    stdout = stdout.replace('RUNNER~1', 'runneradmin')
    expected = expected.replace('RUNNER~1', 'runneradmin')
    assert (stdout, stderr) == (expected, "")

