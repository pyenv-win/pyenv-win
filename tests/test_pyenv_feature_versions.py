from test_pyenv import TestPyenvBase
from test_pyenv_helpers import run_pyenv_test


class TestPyenvFeatureVersions(TestPyenvBase):
    def test_list_no_version(self, setup):
        def commands(ctx):
            assert ctx.pyenv("versions") == ""
        run_pyenv_test({}, commands)

    def test_list_all_versions(self, setup):
        def commands(ctx):
            output = ctx.pyenv("versions")
            for v in versions:
                assert v in output
        versions = ['3.7.4', '3.8.5']
        run_pyenv_test({'versions': versions}, commands)