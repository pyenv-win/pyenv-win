import os
import subprocess
import sys
import pytest
from pathlib import Path
from tempenv import TemporaryEnvironment

from test_pyenv_helpers import Native


@pytest.fixture()
def settings():
    return lambda: {
        'versions': [Native('3.7.7'), Native('3.8.9'), Native('3.10.0')],
        'global_ver': Native('3.7.7'),
        'local_ver': [Native('3.7.7'), Native('3.8.9')]
    }


@pytest.fixture()
def env(pyenv_path):
    env = {"PATH": f"{os.path.dirname(sys.executable)};" \
                     f"{str(Path(pyenv_path, 'bin'))};" \
                     f"{str(Path(pyenv_path, 'shims'))};" \
                     f"{os.environ['PATH']}"}
    environment = TemporaryEnvironment(env)
    with environment:
        yield env


@pytest.fixture(autouse=True)
def remove_python_exe(pyenv, pyenv_path, settings):
    """
    We do not have any python version installed.
    But we prepend the path with sys.executable dir.
    And we remote fake python.exe (empty file generated) to ensure sys.executable is found and used.
    This method allows us to execute python.exe.
    But it cannot be used to play with many python versions.
    """
    pyenv.rehash()
    for v in settings()['versions']:
        os.unlink(str(pyenv_path / 'versions' / v / 'python.exe'))


@pytest.mark.parametrize(
    "command",
    [
        lambda path: [str(path / "bin" / "pyenv.bat"), "exec", "python"],
        lambda path: [str(path / "shims" / "python.bat")],
    ],
    ids=["pyenv exec", "python shim"],
)
@pytest.mark.parametrize(
    "arg",
    [
        "Hello",
        "Hello World",
        "Hello 'World'",
        'Hello "World"',  # " is escaped as \" by python
        "Hello %World%",
        # "Hello %22World%22",
        "Hello !World!",
        "Hello #World#",
        "Hello World'",
        'Hello World"',
        "Hello ''World'",
        'Hello ""World"',
    ],
    ids=[
        "One Word",
        "Two Words",
        "Single Quote",
        "Double Quote",
        "Percentage",
        # "Escaped",
        "Exclamation Mark",
        "Pound",
        "One Single Quote",
        "One Double Quote",
        "Imbalance Single Quote",
        "Imbalance Double Quote",
    ]
)
def test_exec_arg(command, arg, env, pyenv_path, run):
    env['World'] = 'Earth'
    stdout, stderr = run(
        *command(pyenv_path),
        "-c",
        "import sys; print(sys.argv[1])",
        arg,
        env=env
    )
    assert (stdout, stderr) == (arg.replace('%World%', 'Earth'), "")


@pytest.mark.parametrize(
    "args",
    [
        ["--help", "exec"],
        ["help", "exec"],
        ["exec", "--help"],
    ],
    ids=[
        "--help exec",
        "help exec",
        "exec --help",
    ]
)
def test_exec_help(args, env, pyenv):
    stdout, stderr = pyenv(*args, env=env)
    assert ("\r\n".join(stdout.splitlines()[:1]), stderr) == (pyenv_exec_help(), "")


def test_path_not_updated(pyenv_path, local_path, env, run):
    python = str(pyenv_path / "shims" / "python.bat")
    tmp_bat = str(Path(local_path, "tmp.bat"))
    with open(tmp_bat, "w") as f:
        # must chain commands because env var is lost when cmd ends
        print(f'@echo %PATH%', file=f)
        print(f'@call "{python}" -V>nul', file=f)
        print(f'@echo %PATH%', file=f)
    stdout, stderr = run("call", tmp_bat, env=env)
    path = os.environ['PATH']
    assert (stdout, stderr) == (f"{path}\r\n{path}", "")


def test_many_paths(pyenv_path, env, pyenv):
    stdout, stderr = pyenv.exec('python', '-c', "import os; print(os.environ['PATH'])", env=env)
    assert stderr == ""
    assert stdout.startswith(
        (
            rf"{pyenv_path}\versions\{Native('3.7.7')};"
            rf"{pyenv_path}\versions\{Native('3.7.7')}\Scripts;"
            rf"{pyenv_path}\versions\{Native('3.7.7')}\bin;"
            rf"{pyenv_path}\versions\{Native('3.8.9')};"
            rf"{pyenv_path}\versions\{Native('3.8.9')}\Scripts;"
            rf"{pyenv_path}\versions\{Native('3.8.9')}\bin;"
        )
    )
    assert pyenv.exec('version.bat') == ("3.7.7", "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [],
        'local_ver': Native('3.8.5')
    }])
def test_exec_local_not_installed(pyenv):
    with pytest.raises(subprocess.CalledProcessError) as e:
        pyenv.exec('python', check=True)
    assert e.value.returncode == 1


def test_bat_shim(pyenv):
    assert pyenv.exec('hello') == ("Hello world!", "")


def test_removes_shims_from_path(pyenv):
    assert pyenv.exec('python310') == (
        '',
        (
            "'python310' is not recognized as an internal or external command,\r\n"
            'operable program or batch file.'
        )
    )


def pyenv_exec_help():
    return "Usage: pyenv exec <command> [arg1 arg2...]"
