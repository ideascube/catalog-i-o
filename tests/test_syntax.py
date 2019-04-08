import pytest
import yaml


def test_yaml_file(yaml_file):
    try:
        with open(yaml_file, mode='rb') as f:
            yaml.safe_load(f)

    except Exception as e:
        pytest.fail('%s is not valid YAML:\n%s' % (yaml_file, e))
