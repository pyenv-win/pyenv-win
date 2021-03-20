import os
import shutil
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


def install_pyenv(path, versions=None):
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
