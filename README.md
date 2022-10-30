# pyenv for Windows

[pyenv][1] is a great tool. We have ported it to Windows. We need your thoughts to improve this library and your feedback helps to grow the project.

For existing python users, we support [installation via pip](#installation).

Contributors and Interested people can join us on @[Slack](https://join.slack.com/t/pyenv/shared_invite/zt-f9ydwgyt-Fp8tehxqeCQi5mi77RxpGw). Your help keeps us motivated!

[![pytest](https://github.com/pyenv-win/pyenv-win/actions/workflows/pytest.yml/badge.svg)](https://github.com/pyenv-win/pyenv-win/actions/workflows/pytest.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues open](https://img.shields.io/github/issues/pyenv-win/pyenv-win.svg?)](https://github.com/pyenv-win/pyenv-win/issues)
[![Downloads](https://pepy.tech/badge/pyenv-win)](https://pepy.tech/project/pyenv-win)
[![Rate this package](https://badges.openbase.com/python/rating/pyenv-win.svg?token=hjylt9qszl1DzDMCXNqMQZ6ijtlNCYzG3dKZNF+hgk4=)](https://openbase.com/python/pyenv-win?utm_source=embedded&amp;utm_medium=badge&amp;utm_campaign=rate-badge)

- [Introduction](#introduction)
- [pyenv](#pyenv)
- [pyenv-win commands](#pyenv-win-commands)
- [Installation](#installation)
- [Validate installation](#validate-installation)
- [Usage](#usage)
- [How to update pyenv](#how-to-update-pyenv)
- [Announcements](#announcements)
- [FAQ](#faq)
- [Changelog](#changelog)
- [How to contribute](#how-to-contribute)
- [Bug Tracker and Support](#bug-tracker-and-support)
- [License and Copyright](#license-and-copyright)
- [Author and Thanks](#author-and-thanks)

## Introduction

[pyenv][1] for python is a great tool but, like [rbenv][2] for ruby developers, it doesn't directly support Windows. After a bit of research and feedback from python developers, I discovered they wanted a similar feature for Windows systems.

This project was forked from [rbenv-win][3] and modified for [pyenv][1]. It is now fairly mature, thanks to help from many different contributors.

## pyenv

[pyenv][1] is a simple python version management tool. It lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

## Quick start

1. Install pyenv-win in PowerShell.

   ```pwsh
   Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
   ```

2. Reopen PowerShell
3. Run `pyenv --version` to check the installation done
4. Run `pyenv install -l` to check a list of Python versions supported by pyenv-win
5. Run `pyenv install <version>` to install the supported version
6. Run `pyenv global <version>` to set a Python version as the global version
7. Check which Python version you are using and its path

   ```plaintext
   > pyenv version
   <version> (set by \path\to\.pyenv\pyenv-win\.python-version)
   ```

8. Check that Python is working

   ```plaintext
   > python -c "import sys; print(sys.executable)"
   \path\to\.pyenv\pyenv-win\versions\<version>\python.exe
   ```

## pyenv-win commands

```yml
   commands     List all available pyenv commands
   local        Set or show the local application-specific Python version
   global       Set or show the global Python version
   shell        Set or show the shell-specific Python version
   install      Install 1 or more versions of Python 
   uninstall    Uninstall 1 or more versions of Python
   update       Update the cached version DB
   rehash       Rehash pyenv shims (run this after switching Python versions)
   vname        Show the current Python version
   version      Show the current Python version and its origin
   version-name Show the current Python version
   versions     List all Python versions available to pyenv
   exec         Runs an executable by first preparing PATH so that the selected Python
   which        Display the full path to an executable
   whence       List all Python versions that contain the given executable
```

## Installation

Currently we support following ways, choose any of your comfort:

- [PowerShell](docs/installation.md#powershell) - easiest way
- [Git Commands](docs/installation.md#git-commands) - default way + adding manual settings
- [Pyenv-win zip](docs/installation.md#pyenv-win-zip) - manual installation
- [Python pip](docs/installation.md#python-pip) - for existing users
- [Chocolatey](docs/installation.md#chocolatey)
- [How to use 32-train](docs/installation.md#how-to-use-32-train)
  - [check announcements](#announcements)

Please see the [Installation](./docs/installation.md) page for more details.

## Validate installation

1. Reopen the command prompt and run `pyenv --version`
2. Now type `pyenv` to view it's usage

If you are getting "**command not found**" error, check the below note and [manually check the settings](#manually-check-the-settings)

For Visual Studio Code or another IDE with a built in terminal, restart it and check again  

***

### Manually check the settings

Ensure all environment variables are properly set via the GUI:

```plaintext
This PC 
   → Properties
      → Advanced system settings 
         → Advanced → Environment Variables... 
            → PATH
```

**NOTE:** If you are running Windows 10 1905 or newer, you might need to disable the built-in Python launcher via Start > "Manage App Execution Aliases" and turning off the "App Installer" aliases for Python

## Usage

- To view a list of python versions supported by pyenv windows: `pyenv install -l`
- To filter the list: `pyenv install -l | findstr 3.8`
- To install a python version:  `pyenv install 3.5.2`
  - _Note: An install wizard may pop up for some non-silent installs. You'll need to click through the wizard during installation. There's no need to change any options in it. or you can use -q for quiet installation_
  - You can also install multiple versions in one command too: `pyenv install 2.4.3 3.6.8`
- To set a python version as the global version: `pyenv global 3.5.2`
  - This is the version of python that will be used by default if a local version (see below) isn't set.
  - _Note: The version must first be installed._
- To set a python version as the local version: `pyenv local 3.5.2`.
  - The version given will be used whenever `python` is called from within this folder. This is different than a virtual env, which needs to be explicitly activated.
  - _Note: The version must first be installed._
- After (un)installing any libraries using pip or modifying the files in a version's folder, you must run `pyenv rehash` to update pyenv with new shims for the python and libraries' executables.
  - _Note: This must be run outside of the `.pyenv` folder._
- To uninstall a python version: `pyenv uninstall 3.5.2`
- To view which python you are using and its path: `pyenv version`
- To view all the python versions installed on this system: `pyenv versions`
- Update the list of discoverable Python versions using: `pyenv update` command for pyenv-win `2.64.x` and `2.32.x` versions

## How to update pyenv

- If installed via pip
  - Add your pyenv-win installation path to `easy_install.pth` file located in site-packages. This should make pip recognise pyenv-win as installed.
  - Get updates via pip `pip install --upgrade pyenv-win`
- If installed via Git
  - Go to `%USERPROFILE%\.pyenv\pyenv-win` (which is your installed path) and run `git pull`
- If installed via zip
  - Download the latest zip and extract it
  - Go to `%USERPROFILE%\.pyenv\pyenv-win` and replace the folders `libexec` and `bin` with the new ones you just downloaded
- If installed via the installer
  - Run the following in a Powershell terminal: `&"${env:PYENV_HOME}\install-pyenv-win.ps1"`

## Announcements

To keep in sync with [pyenv][1] linux/mac, pyenv-win now installs 64bit versions by default. To support compatibility with older versions of pyenv-win, we maintain a 32bit train (branch) as a separate release.

Both releases can install 64bit and 32bit python versions; the difference is in version names, for example:

- 64bit-train (master), i.e. pyenv version _2.64.x_

```plaintext
> pyenv install -l | findstr 3.8
....
3.8.0-win32
3.8.0
3.8.1rc1-win32
3.8.1rc1
3.8.1-win32
3.8.1
3.8.2-win32
3.8.2
3.9.0-win32
3.9.0
....
```

- 32bit-train, i.e. pyenv version _2.32.x_

```plaintext
> pyenv install -l | findstr 3.8
....
3.8.0
3.8.0-amd64
3.8.1rc1
3.8.1rc1-amd64
3.8.1
3.8.1-amd64
3.8.2
3.8.2-amd64
....
```
  
Support for Python versions below 2.4 have been dropped since their installers don't install "cleanly" like versions from 2.4 onward and they're predominantly out of use/support in most environments now.

## FAQ

Please see the [FAQ](./docs/faq.md) page.

## Changelog

Please see the [Changelog](./docs/changelog.md) page.

## How to contribute

- Fork the project & clone locally.
- Create an upstream remote and sync your local copy before you branch.
- Branch for each separate piece of work. It's good practice to write test cases.
- Do the work, write good commit messages, and read the CONTRIBUTING file if there is one.
- Test the changes by running `tests\bat_files\test_install.bat` and `tests\bat_files\test_uninstall.bat`
- Push to your origin repository.
- Create a new Pull Request in GitHub.

## Bug Tracker and Support

- Please report any suggestions, bug reports, or annoyances with pyenv-win through the [GitHub bug tracker](https://github.com/pyenv-win/pyenv-win/issues).

## License and Copyright

- pyenv-win is licensed under [MIT](http://opensource.org/licenses/mit-license.php) _2019_

   [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Author and Thanks

pyenv-win was developed by [Kiran Kumar Kotari](https://github.com/kirankotari) and [Contributors](https://github.com/pyenv-win/pyenv-win/graphs/contributors)  
Thanks for all Contributors and Supports for patience for the latest major release.

[1]: https://github.com/pyenv/pyenv
[2]: https://github.com/rbenv/rbenv
[3]: https://github.com/nak1114/rbenv-win
