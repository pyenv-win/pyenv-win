import pytest

from test_pyenv_helpers import not_installed_output, global_python_versions, Native, Arch


def pyenv_global_help():
    return (f"Usage: pyenv global <version>\r\n"
            f"       pyenv global --unset")


def test_global_help(pyenv):
    for args in [
        ["--help", "global"],
        ["help", "global"],
        ["global", "--help"],
    ]:
        stdout, stderr = pyenv(*args)
        assert ("\r\n".join(stdout.splitlines()[:2]), stderr) == (pyenv_global_help(), "")


def test_global_no_version(pyenv):
    assert pyenv("global") == ("no global version configured", "")


@pytest.mark.parametrize('settings', [lambda: {'global_ver': Native("3.8.9")}])
def test_global_version_defined(pyenv):
    assert pyenv("global") == (Native("3.8.9"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.7.7"), Native("3.8.9")],
        'global_ver': Native("3.8.9")
    }])
def test_global_set_installed_version(pyenv):
    assert pyenv("global", Arch("3.7")) == ("", "")
    assert pyenv("global") == (Arch("3.7"), "")

    assert pyenv("global", Arch("3.7.7")) == ("", "")
    assert pyenv("global") == (Arch("3.7.7"), "")

    assert pyenv("global", Native("3.7.7")) == ("", "")
    assert pyenv("global") == (Native("3.7.7"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.8.9")],
        'global_ver': Native("3.8.9"),
    }])
def test_global_set_unknown_version(pyenv):
    assert pyenv("global", Arch("3.7")) == (not_installed_output(Arch("3.7")), "")
    assert pyenv("global", Arch("3.7.8")) == (not_installed_output(Arch("3.7.8")), "")
    assert pyenv("global", Native("3.7.8")) == (not_installed_output(Native("3.7.8")), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.8.9")],
        'global_ver': Native("3.8.9"),
    }])
def test_global_unset(pyenv):
    assert pyenv("global", "--unset") == ("", "")
    assert pyenv("global") == ("no global version configured", "")


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.7.7"), Native("3.8.9")]}])
def test_global_set_many_versions(pyenv_path, pyenv):
    assert pyenv('global', Arch("3.7.7"), Arch("3.8.9")) == ("", "")
    assert global_python_versions(pyenv_path) == "\n".join([Arch('3.7.7'), Arch('3.8.9')])

    assert pyenv('global', Arch("3.7.7"), Arch("3.8.9")) == ("", "")
    assert global_python_versions(pyenv_path) == "\n".join([Arch('3.7.7'), Arch('3.8.9')])


@pytest.mark.parametrize('settings', [lambda: {'versions': [Native("3.7.7")]}])
def test_global_set_many_versions_one_not_installed(pyenv):
    assert pyenv('global', Arch("3.7.7"), Arch("3.8.9")) == (not_installed_output(Arch("3.8.9")), "")


@pytest.mark.parametrize('settings', [lambda: {'global_ver': [Native('3.7.7'), Native('3.8.9')]}])
def test_global_many_versions_defined(pyenv):
    assert pyenv('global') == ("\r\n".join([Native('3.7.7'), Native('3.8.9')]), "")
