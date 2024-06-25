import pytest

import os
from test_pyenv_helpers import Native


def test_check_pyenv_install_list(pyenv):
    result, stderr = pyenv.install('-l')
    assert stderr == ""
    assert "Mirror: https://www.python.org/ftp/python" in result
    assert "2.7.17-win32" in result
    assert "2.7.17" in result
    assert "3.1.4-win32" in result
    assert "3.1.4" in result
    assert "3.2.5-win32" in result
    assert "3.2.5" in result
    assert "3.3.5-win32" in result
    assert "3.3.5" in result
    assert "3.4.4-win32" in result
    assert "3.4.4" in result
    assert "3.5.4-win32" in result
    assert "3.5.4" in result
    assert "3.6.8-win32" in result
    assert "3.6.8" in result
    assert "3.7.7-win32" in result
    assert "3.7.7" in result
    assert "3.8.2-win32" in result
    assert "3.8.2" in result
    assert "3.9.0-win32" in result
    assert "3.9.0" in result
    assert "3.9.1-win32" in result
    assert "3.9.1" in result
    assert "graalpy" in result
    assert "pypy" in result


def test_check_pyenv_installation():
    # TODO: tracking the logs of installation and checking the folder
    pass


@pytest.mark.parametrize("version, python", (("3.9.13", "python39"), ("3.10.11", "python310"), ("3.11.3", "python311")))
def test_patched_venv_module(version, python, arch, pyenv, run, tmp_path):
    if arch != os.environ["PROCESSOR_ARCHITECTURE"]:
        pytest.skip()
    pyenv.install(Native(version), check=True)
    pyenv.rehash(check=True)
    pyenv("global", Native(version), check=True)
    pyenv.exec(python, "-m", "venv", str(tmp_path / "venv"), check=True)
    stdout, stderr = run(str(tmp_path / "venv" / "Scripts" / "pip.exe"), "--version")
    assert stderr == "", stdout

