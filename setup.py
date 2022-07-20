from setuptools import setup, find_packages
from os import path
from io import open

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

with open(path.join(here, '.version'), encoding='utf-8') as f:
    version = f.read()

setup(
    name = 'pyenv-win',
    version = version,
    description = "pyenv lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.",
    long_description = long_description,
    long_description_content_type = 'text/markdown',
    url = 'https://github.com/pyenv-win/pyenv-win.git',
    author = 'Kiran Kumar Kotari',
    author_email = 'kirankotari@live.com',
    classifiers = [
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',
        'License :: OSI Approved :: MIT License',
        'Operating System :: Microsoft :: Windows',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.1',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10'
        ],
    keywords = 'pyenv for windows, multiple versions of python',
    packages = find_packages(
        exclude=['tests']
    ),
    package_dir = {
        'pyenv-win': 'pyenv-win'
    },
    package_data = {
        'pyenv-win': 
        [
            'bin/*', 
            'bin/WiX/*',
            'libexec/*', 
            'libexec/libs/*', 
            '../.version', 
            '.versions_cache.xml'
        ]
    },
)
