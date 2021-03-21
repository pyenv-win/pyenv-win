from test_pyenv import TestPyenvBase
from test_pyenv_helpers import temp_pyenv


class TestPyenvFeatureVersions(TestPyenvBase):
    def test_list_no_version(self, setup):
        with temp_pyenv("versions") as output:
            assert output == ""

    def test_list_all_versions(self, setup):
        versions = ['3.7.4', '3.8.5']
        with temp_pyenv("versions", versions=versions) as output:
            for v in versions:
                assert v in output
