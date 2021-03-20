import os
import shutil
import subprocess
import tempfile
from contextlib import contextmanager
from pathlib import Path


@contextmanager
def working_directory(path):
    prev_cwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def install_pyenv(path, versions=None, global_ver=None):
    if versions is None:
        versions = []
    src_path = Path(__file__).resolve().parents[1].joinpath('pyenv-win')
    dirs = [r'bin', r'libexec\libs', r'shims', r'versions']
    for d in dirs:
        os.makedirs(Path(path, d))
    files = [r'bin\pyenv.bat',
             r'libexec\pyenv.vbs',
             r'libexec\libs\pyenv-install-lib.vbs',
             r'libexec\libs\pyenv-lib.vbs']
    for f in files:
        shutil.copy(src_path.joinpath(f), Path(path, f))
    versions_dir = Path(path, r'versions')
    for v in versions:
        os.mkdir(versions_dir.joinpath(v))
    if global_ver is not None:
        with open(Path(path, "version"), "w") as f:
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
