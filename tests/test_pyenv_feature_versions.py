import pytest

from test_pyenv_helpers import Native


def test_list_no_version(pyenv):
    assert pyenv.versions() == ("", "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native('3.7.4'), Native('3.8.5')]}])
def test_list_all_versions(settings, pyenv):
    stdout, stderr = pyenv.versions()
    for v in settings()['versions']:
        assert v in stdout
    assert stderr == ""


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.7")
    }])
def test_list_current_global_version(pyenv_path, pyenv):
    assert pyenv.versions() == (
        (
            f"  {Native('3.6.5')}\r\n"
            f"* {Native('3.7.7')} (set by {pyenv_path}\\version)\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.7"),
        'local_ver': Native("3.6.5")
    }])
def test_list_current_local_version(local_path, pyenv):
    assert pyenv.versions() == (
        (
            f"* {Native('3.6.5')} (set by {local_path}\\.python-version)\r\n"
            f"  {Native('3.7.7')}\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.9.1"),
        'local_ver': [Native('3.6.5'), Native('3.7.7')]
    }])
def test_list_current_local_many_versions(local_path, pyenv):
    assert pyenv.versions() == (
        (
            f"* {Native('3.6.5')} (set by {local_path}\\.python-version)\r\n"
            f"* {Native('3.7.7')} (set by {local_path}\\.python-version)\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.7"),
        'local_ver': Native("3.6.5")
    }])
def test_list_current_shell_version(pyenv):
    env = {"PYENV_VERSION": Native("3.9.1")}
    assert pyenv.versions(env=env) == (
        (
            f"  {Native('3.6.5')}\r\n"
            f"  {Native('3.7.7')}\r\n"
            f"* {Native('3.9.1')} (set by %PYENV_VERSION%)"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.5")
    }])
def test_list_uninstalled_current_global_version(pyenv):
    assert pyenv.versions() == (
        (
            f"  {Native('3.6.5')}\r\n"
            f"  {Native('3.7.7')}\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.7"),
        'local_ver': Native("3.6.1")
    }])
def test_list_uninstalled_local_version(pyenv):
    assert pyenv.versions() == (
        (
            f"  {Native('3.6.5')}\r\n"
            f"  {Native('3.7.7')}\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.6.5"), Native("3.7.7"), Native("3.9.1")],
        'global_ver': Native("3.7.7"),
        'local_ver': Native("3.6.5")
    }])
def test_list_uninstalled_shell_version(pyenv):
    env = {"PYENV_VERSION": Native("3.9.2")}
    assert pyenv.versions(env=env) == (
        (
            f"  {Native('3.6.5')}\r\n"
            f"  {Native('3.7.7')}\r\n"
            f"  {Native('3.9.1')}"
        ),
        ""
    )
