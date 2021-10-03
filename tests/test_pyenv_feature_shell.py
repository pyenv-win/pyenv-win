import pytest

from pathlib import Path
from tempenv import TemporaryEnvironment
from test_pyenv_helpers import not_installed_output, Native, Arch


def pyenv_shell_help():
    return (f"Usage: pyenv shell <version>\r\n"
            f"       pyenv shell --unset")


def test_shell_help(pyenv):
    for args in [
        ["--help", "shell"],
        ["help", "shell"],
        ["shell", "--help"],
    ]:
        stdout, stderr = pyenv(*args)
        assert ("\r\n".join(stdout.splitlines()[:2]), stderr) == (pyenv_shell_help(), "")


def test_no_shell_version(pyenv):
    with TemporaryEnvironment({"PYENV_VERSION": ""}):
        assert pyenv.shell() == ("no shell-specific version configured", "")


def test_shell_version_defined(pyenv):
    with TemporaryEnvironment({"PYENV_VERSION": Native("3.9.2")}):
        assert pyenv.shell() == (Native("3.9.2"), "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.7.7"), Native("3.8.9")]}])
def test_shell_set_installed_version(pyenv_bat, local_path, exec):
    with TemporaryEnvironment({"PYENV_VERSION": Native("3.8.9")}):
        tmp_bat = str(Path(local_path, "tmp.bat"))
        with open(tmp_bat, "w") as f:
            # must chain commands because env var is lost when cmd ends
            print(f'@call "{pyenv_bat}" shell {Arch("3.7.7")} && call "{pyenv_bat}" shell', file=f)
        stdout, stderr = exec(tmp_bat)
        assert (stdout, stderr) == (Native("3.7.7"), "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.8.9")]}])
def test_shell_set_unknown_version(pyenv):
    assert pyenv.shell(Native("3.7.8")) == (not_installed_output(Native("3.7.8")), "")
