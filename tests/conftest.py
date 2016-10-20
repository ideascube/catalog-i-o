import os


def get_files(extension):
    for root, dirnames, filenames in os.walk('.'):
        for filename in filenames:
            if filename.endswith(extension):
                yield os.path.join(root, filename)


def pytest_generate_tests(metafunc):
    if 'yaml_file' in metafunc.fixturenames:
        metafunc.parametrize('yaml_file', get_files('.yml'))
