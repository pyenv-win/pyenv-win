import sys

import pytest
from tempenv import TemporaryEnvironment

import os
import subprocess
from pathlib import Path
from test_pyenv_helpers import touch, pyenv_setup, do_run


@pytest.fixture()
def shell():
    return "cmd"


@pytest.fixture()
def shell_ext(shell):
    if shell == 'cmd':
        return '.bat'
    if shell in ['powershell', 'pwsh']:
        return '.ps1'


@pytest.fixture()
def src_path():
    return Path(__file__).parent.parent


@pytest.fixture()
def local_path(tmp_path):
    return tmp_path / 'local dir with spaces'


@pytest.fixture()
def pyenv_path(tmp_path):
    return tmp_path / 'pyenv dir with spaces'


@pytest.fixture()
def bin_path(pyenv_path):
    return pyenv_path / 'bin'


@pytest.fixture()
def shims_path(pyenv_path):
    return pyenv_path / 'shims'


@pytest.fixture()
def current_arch():
    return os.environ['PYENV_FORCE_ARCH']


@pytest.fixture()
def pyenv_file(shell, bin_path, shell_ext):
    pyenv_file = str(Path(bin_path, 'pyenv' + shell_ext))
    if shell in ['powershell', 'pwsh']:
        pyenv_file = pyenv_file.replace(' ', '` ')
    return pyenv_file


@pytest.fixture(scope='session', autouse=True, params=['AMD64', 'X86'],
                ids=['PYENV_FORCE_ARCH=AMD64', 'PYENV_FORCE_ARCH=X86'])
def arch(request):
    value = request.param
    if request.session.testsfailed:
        pytest.skip(f'Skipping PYENV_FORCE_ARCH={value} since at lease one test failed for PYENV_FORCE_ARCH=AMD64')
    with(TemporaryEnvironment({'PYENV_FORCE_ARCH': value})):
        yield value


@pytest.fixture()
def settings(arch):
    # This needs to return a callable so that `__new__` of Native and its siblings gets called after `PYENV_FORCE_ARCH`
    # has been set by the `arch` fixture instead of `__new__` being called during pytest's collection phase.
    return lambda: {}


@pytest.fixture(autouse=True)
def tmp_pyenv(tmp_path, pyenv_path, local_path, bin_path, shims_path, settings, arch):
    settings = settings()
    touch(tmp_path / '.python-version')
    settings['pyenv_path'] = pyenv_path
    settings['local_path'] = local_path
    os.mkdir(pyenv_path)
    os.mkdir(local_path)
    pyenv_setup(settings)
    prev_cwd = os.getcwd()
    os.chdir(local_path)
    yield
    os.chdir(prev_cwd)


@pytest.fixture()
def run_args(shell):
    if shell == 'cmd':
        return ['cmd', '/d', '/c', 'call']
    if shell == 'powershell':
        return ['powershell', '-Command']
    if shell == 'pwsh':
        return ['pwsh', '-Command']


@pytest.fixture()
def run(run_args, pyenv_path, bin_path, shims_path):
    environ = os.environ.copy()
    for key in ['PYENV', 'PYENV_ROOT', 'PYENV_HOME']:
        if key in environ:
            environ[key] = str(pyenv_path)
            environ['PATH'] = environ['PATH'].replace(str(Path(os.environ[key])), environ[key])

    def remove_python_paths(path):
        path = Path(path)
        if path.joinpath("python.exe").exists():
            return False
        if path.parent.name.lower() == "scripts" and path.parent.joinpath("python.exe").exists():
            return False
        return True

    environ["PATH"] = os.pathsep.join(filter(remove_python_paths, environ["PATH"].split(os.pathsep)))
    environ.pop("VIRTUAL_ENV", None)

    def run(*args, **kwargs):
        env = {**environ, **kwargs.pop("env", {})}
        env.pop("PYTHONPATH", None)
        args = run_args + list(args)
        return do_run(*args, env=env, **kwargs)

    with TemporaryEnvironment({'PATH': environ['PATH']}):
        return run


@pytest.fixture()
def pyenv(tmp_pyenv, pyenv_file, run):
    class PyEnv:
        def __getattr__(self, item):
            def command(*args, **kwargs):
                return run(pyenv_file, item, *args, **kwargs)

            return command

        def __call__(self, *args, **kwargs):
            return run(pyenv_file, *args, **kwargs)

    return PyEnv()
