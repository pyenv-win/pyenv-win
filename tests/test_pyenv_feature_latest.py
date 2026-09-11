import pytest
from test_pyenv_helpers import Native, X86, Arm, Arch


def test_latest_help(pyenv):
    assert pyenv("latest")

    result, stderr = pyenv("latest")

    assert "Usage:" in result
    assert "--known" in result
    assert "--quiet" in result


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [
            Native("3.1.4"), Native("3.11.0"),
            Native("3.2.0"), Native("3.2.5"),
            Native("3.9.1")
        ]
    }])
def test_latest_edge_cases(pyenv):
    assert pyenv.latest("1") == ("pyenv-latest: no installed versions match the prefix '1'.", "")
    assert pyenv.latest("-k", "1") == ("pyenv-latest: no known versions match the prefix '1'.", "")
    assert pyenv.latest("-k", "3.2.16") == ("pyenv-latest: no known versions match the prefix '3.2.16'.", "")
    assert pyenv.latest("3.1") == (Native("3.1.4"), "")
    assert pyenv.latest("3.2") == (Native("3.2.5"), "")
    assert pyenv.latest("3.2.5") == (Native("3.2.5"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [X86("3.1.0"), Arch("3.1.4")]
    }])
def test_latest_arch_cases(pyenv, current_arch):
    if current_arch == 'X86':
        assert pyenv.latest("3.1") == (X86("3.1.0"), "")
    else:
        # No -arm build is installed here, so ARM64 resolves to the x64 build too.
        assert pyenv.latest("3.1") == (Arch("3.1.4"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [X86("3.1.0"), Arch("3.1.4"), Arm("3.1.2")]
    }])
def test_latest_prefers_native_arm(pyenv, current_arch):
    if current_arch == 'X86':
        assert pyenv.latest("3.1") == (X86("3.1.0"), "")
    elif current_arch == 'ARM64':
        assert pyenv.latest("3.1") == (Arm("3.1.2"), "")
    else:
        assert pyenv.latest("3.1") == (Arch("3.1.4"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Arch("3.1.4")]
    }])
def test_latest_arm_falls_back_to_x64(pyenv, current_arch):
    if current_arch == 'X86':
        pytest.skip('x86 cannot run x64 builds')
    assert pyenv.latest("3.1") == (Arch("3.1.4"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [X86("3.1.0"), Arch("3.1.4"), Arm("3.1.2")]
    }])
def test_latest_partial_prefix_with_arch(pyenv):
    # A pinned architecture applies to the prefix search, whatever the host is.
    assert pyenv.latest("3.1-win32") == (X86("3.1.0"), "")
    assert pyenv.latest("3.1-arm") == (Arm("3.1.2"), "")
    assert pyenv.latest("3.1-arm64") == (Arm("3.1.2"), "")
    assert pyenv.latest("3.1-amd64") == (Arch("3.1.4"), "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [X86("3.1.0"), Arch("3.1.4")]
    }])
def test_latest_pinned_arch_does_not_fall_back(pyenv):
    # No ARM build is installed, and an explicit request must not silently pick another.
    assert pyenv.latest("3.1-arm") == ("pyenv-latest: no installed versions match the prefix '3.1-arm'.", "")


def test_latest_quiet(pyenv):
    assert pyenv.latest("-q") == ("", "")
    assert pyenv.latest("-q", "-k") == ("", "")
    assert pyenv.latest("-k", "-q") == ("", "")
    assert pyenv.latest("-q", "-k", "1.") == ("", "")
    assert pyenv.latest("-q", "-k", "www") == ("", "")


@pytest.mark.parametrize('settings', [lambda: {
        'versions': [Native("3.9.4"), Native("3.7.2"), Native("3.7.7"), Native("3.9.1")]
    }])
def test_latest_sort(pyenv):
    assert pyenv.latest('3') == (Native('3.9.4'), '')
    assert pyenv.latest('3.7') == (Native('3.7.7'), '')
