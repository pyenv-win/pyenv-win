

def test_help(pyenv):
    stdout, stderr = pyenv.help()
    stdout = "\r\n".join(stdout.splitlines()[:2])
    assert (stdout.strip(), stderr) == ("Usage: pyenv <command> [<args>]", "")
