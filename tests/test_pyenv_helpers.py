import os
import shutil
import subprocess
import tempfile
from contextlib import contextmanager
from packaging import version
from pathlib import Path


@contextmanager
def working_directory(path):
    prev_cwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def python_exes(suffixes=None):
    if suffixes is None:
        suffixes = [""]
    else:
        suffixes.append("")
    for suffix in suffixes:
        yield f'python{suffix}.exe'
        yield f'pythonw{suffix}.exe'


def script_exes(ver):
    for suffix in ['', f'{ver.major}', f'{ver.major}{ver.minor}']:
        yield f'pip{suffix}.exe'
    for suffix in ['', f'-{ver.major}.{ver.minor}']:
        yield f'easy_install{suffix}.exe'


def install_pyenv(root_path, versions=None, global_ver=None):
    if versions is None:
        versions = []
    src_path = Path(__file__).resolve().parents[1].joinpath('pyenv-win')
    dirs = [r'bin', r'libexec\libs', r'shims', r'versions']
    for d in dirs:
        os.makedirs(Path(root_path, d))
    files = [r'bin\pyenv.bat',
             r'libexec\pyenv.vbs',
             r'libexec\libs\pyenv-install-lib.vbs',
             r'libexec\libs\pyenv-lib.vbs']
    for f in files:
        shutil.copy(src_path.joinpath(f), Path(root_path, f))
    versions_dir = Path(root_path, r'versions')

    def touch(exe):
        with open(exe, 'a'):
            os.utime(exe, None)

    def create_pythons(path):
        os.mkdir(path)
        for exe in python_exes([f'{ver.major}', f'{ver.major}{ver.minor}']):
            touch(path.joinpath(exe))
        return path

    def create_scripts(path):
        os.mkdir(path)
        for exe in script_exes(ver):
            touch(path.joinpath(exe))

    for v in versions:
        ver = version.parse(v)
        version_path = create_pythons(versions_dir.joinpath(v))
        create_scripts(version_path.joinpath('Scripts'))
    if global_ver is not None:
        with open(Path(root_path, "version"), "w") as f:
            print(global_ver, file=f)


@contextmanager
def temp_pyenv(command, option=None, versions=None, global_ver=None):
    if versions is None:
        versions = []
    with tempfile.TemporaryDirectory() as tmp_path:
        install_pyenv(tmp_path, versions, global_ver)
        with working_directory(tmp_path):
            bat = Path(tmp_path, r'bin\pyenv.bat')
            args = ['cmd', '/d', '/c', f'call {bat}', command]
            if option is not None:
                args.append(option)
            result = subprocess.run(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            result = str(result.stdout, "utf-8").strip()
            yield result
