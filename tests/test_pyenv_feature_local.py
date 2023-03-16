import pytest

from test_pyenv_helpers import local_python_versions, not_installed_output, Native, Arch


def test_no_local_version(pyenv):
    assert pyenv.local() == ("no local version configured for this directory", "")


@pytest.mark.parametrize('settings', [lambda: {'local_ver': Native("3.8.9")}])
def test_local_version_defined(pyenv):
    assert pyenv.local() == (Native("3.8.9"), "")


@pytest.mark.parametrize('settings', [lambda: {
    'versions': [Native("3.7.7"), Native("3.8.9")],
    'local_ver': Native("3.8.9"),
}])
def test_local_set_installed_version(pyenv):
    assert pyenv.local(Arch("3.7.7")) == ("", "")
    assert pyenv.local() == (Arch("3.7.7"), "")


@pytest.mark.parametrize('settings', [lambda: {
    'versions': [Native("3.7.7"), Native("3.8.9")],
    'local_ver': Native("3.8.9"),
}])
def test_local_set_minor_version(pyenv):
    assert pyenv.local(Arch("3.7")) == ("", "")
    assert pyenv.local() == (Arch("3.7"), "")
    assert pyenv.vname() == (Native("3.7.7"), "")

    assert pyenv.local(Arch("3")) == ("", "")
    assert pyenv.local() == (Arch("3"), "")
    assert pyenv.vname() == (Native("3.8.9"), "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.8.9")]}])
def test_local_set_unknown_version(pyenv):
    assert pyenv.local(Arch("3.7.8")) == (not_installed_output(Arch("3.7.8")), "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.7.7"), Native("3.8.9")]}])
def test_local_set_many_versions(local_path, pyenv):
    assert pyenv.local(Native("3.7.7"), Native("3.8.9")) == ("", "")
    assert local_python_versions(local_path) == "\n".join([Native('3.7.7'), Native('3.8.9')])


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.7.7")]}])
def test_local_set_many_versions_one_not_installed(pyenv):
    assert pyenv.local(Arch("3.7.7"), Arch("3.8.9")) == (not_installed_output(Arch("3.8.9")), "")


@pytest.mark.parametrize('settings', [lambda: {'local_ver': [Native('3.7.7'), Native('3.8.9')]}])
def test_local_many_versions_defined(pyenv):
    assert pyenv.local() == ("\r\n".join([Native('3.7.7'), Native('3.8.9')]), "")
