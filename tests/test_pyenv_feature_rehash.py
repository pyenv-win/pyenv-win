import pytest
from packaging import version
from pathlib import Path
from test_pyenv_helpers import python_exes, script_exes, Native


def assert_shims(pyenv_path, ver):
    shims_path = Path(pyenv_path, 'shims')
    ver = version.parse(ver.version)
    suffixes = [f'{ver.major}', f'{ver.major}{ver.minor}', f'{ver.major}.{ver.minor}']
    all_exes = [Path(n).stem for n in list(python_exes(suffixes)) + list(script_exes(ver))]
    all_shims = [n + s for n in all_exes for s in ['', '.bat']]
    for s in all_shims:
        assert shims_path.joinpath(s).is_file()


def test_rehash_no_version(pyenv):
    assert pyenv.rehash() == (
        "No version installed. Please install one with 'pyenv install <version>'.",
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
    'versions': [Native('3.8.6'), Native('3.8.7')],
    'global_ver': Native('3.8.6'),
}])
def test_rehash_global_version(pyenv_path, pyenv):
    assert pyenv.rehash() == ("", "")
    assert_shims(pyenv_path, Native('3.8.6'))
    assert_shims(pyenv_path, Native('3.8.7'))


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.8.6'), Native('3.9.1')],
        'global_ver': Native('3.8.6'),
        'local_ver': Native('3.9.1')
    }])
def test_rehash_local_version(pyenv_path, pyenv):
    assert pyenv.rehash() == ("", "")
    assert_shims(pyenv_path, Native('3.8.6'))
    assert_shims(pyenv_path, Native('3.9.1'))


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native('3.7.5'), Native('3.8.6'), Native('3.9.1')],
        'global_ver': Native('3.7.5'),
        'local_ver': Native('3.8.6')
    }])
def test_rehash_shell_version(pyenv):
    env = {"PYENV_VERSION": Native('3.9.1')}
    assert pyenv.rehash(env=env) == ("", "")
