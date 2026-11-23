import pytest

from pathlib import Path
from test_pyenv_helpers import Arch, Arm


def installed_versions(pyenv_path):
    return sorted(p.name for p in Path(pyenv_path, 'versions').iterdir() if p.is_dir())


# 9.9.9 keeps `unregister` away from any Python version a developer may have registered
# under HKCU, since uninstall deletes those keys for real.
@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Arch("9.9.9"), Arm("9.9.9")]
    }])
def test_uninstall_all_removes_every_architecture(pyenv, pyenv_path):
    assert installed_versions(pyenv_path) == ["9.9.9", "9.9.9-arm"]
    stdout, stderr = pyenv.uninstall("--all", "-f")
    assert stderr == ""
    assert installed_versions(pyenv_path) == []


@pytest.mark.parametrize('settings', [lambda: {'versions': [Arm("9.9.9")]}])
def test_uninstall_accepts_arm64_spelling(pyenv, pyenv_path):
    stdout, stderr = pyenv.uninstall("-f", "9.9.9-arm64")
    assert stderr == ""
    assert installed_versions(pyenv_path) == []


@pytest.mark.parametrize('settings', [lambda: {'versions': [Arm("9.9.9")]}])
def test_uninstall_bare_name_resolves_to_native_build(pyenv, pyenv_path, current_arch):
    if current_arch != 'ARM64':
        pytest.skip('only ARM64 resolves a bare name to the -arm build')
    stdout, stderr = pyenv.uninstall("-f", "9.9.9")
    assert stderr == ""
    assert installed_versions(pyenv_path) == []
