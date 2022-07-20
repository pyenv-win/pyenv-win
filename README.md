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
- [Usage](#usage)
- [How to update pyenv](#how-to-update-pyenv)
- [Announcements](#announcements)
- [FAQ](#faq)
- [How to contribute](#how-to-contribute)
- [Bug Tracker and Support](#bug-tracker-and-support)
- [License and Copyright](#license-and-copyright)
- [Author and Thanks](#author-and-thanks)


## Introduction

[pyenv][1] for python is a great tool but, like [rbenv][2] for ruby developers, it doesn't directly support Windows. After a bit of research and feedback from python developers, I discovered they wanted a similar feature for Windows systems.

This project was forked from [rbenv-win][3] and modified for [pyenv][1]. It is now fairly mature, thanks to help from many different contributors.

## pyenv

[pyenv][1] is a simple python version management tool. It lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

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

- [Power Shell](#power-shell) - easiest way
- [Git Commands](#git-commands) - default way + adding manual settings
- [Pyenv-win zip](#pyenv-win-zip) - manual installation
- [Python pip](#python-pip) - for existing users
- [Chocolatey](#Chocolatey)
- [How to use 32-train](#how-to-use-32-train)  
   - [check announcements](#Announcements)

Hurray! When you are done here are steps to [Validate](#validate)

_NOTE:_ If you are running Windows 10 1905 or newer, you might need to disable the built-in Python launcher via Start > "Manage App Execution Aliases" and turning off the "App Installer" aliases for Python

***

#### **Power Shell**

The easiest way to install pyenv-win is to run the following installation command in a PowerShell terminal:

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

If you are getting any **UnauthorizedAccess** error as below then start Windows PowerShell with the "Run as administrator" option and run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine`, now re-run the above installation command. 

```pwsh
& : File C:\Users\kirankotari\install-pyenv-win.ps1 cannot be loaded because running scripts is disabled on this system. For
more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:173
+ ... n.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
+ ~~~~~~~~~~~~~~~~~~~~~~~~~ 
 + CategoryInfo          : SecurityError: (:) [], PSSecurityException 
 + FullyQualifiedErrorId : UnauthorizedAccess
```

For more information on 'digitally signed' or 'Security warning' you can refer to following issue [#332](https://github.com/pyenv-win/pyenv-win/issues/332)

Installation is complete!

***

#### **Git Commands**

The default way to install pyenv-win, it needs git commands you need to install git/git-bash for windows

If you are using PowerShell or Git Bash use `$HOME` instead of `%USERPROFILE%`

git clone using command prompt `git clone https://github.com/pyenv-win/pyenv-win.git "%USERPROFILE%\.pyenv"`

steps to [add System Settings](#add-system-settings)

_Note:_ Don't forget the check above link, it contains final steps to complete.

Installation is complete!

***

#### **Pyenv-win zip**

Manual installation steps for pyenv-win

If you are using PowerShell or Git Bash use `$HOME` instead of `%USERPROFILE%`

1. Download [pyenv-win.zip](https://github.com/pyenv-win/pyenv-win/archive/master.zip)

2. Create a `.pyenv` directory using command prompt `mkdir %USERPROFILE%/.pyenv` if not exist

3. Extract and move files to `%USERPROFILE%\.pyenv\`

4. Ensure there is a `bin` folder under `%USERPROFILE%\.pyenv\pyenv-win`

steps to [add System Settings](#add-system-settings)

_Note:_ Don't forget the check above link, it contains final steps to complete.

Installation is complete!

***

#### **Python pip**

For existing python users

If you are using PowerShell or Git Bash use `$HOME` instead of `%USERPROFILE%`

installation command via command prompt  
`pip install pyenv-win --target %USERPROFILE%\\.pyenv`  

if you having an error on above command use the folllowing to resolve it. ref. link [#303](https://github.com/pyenv-win/pyenv-win/issues/303)  
`pip install pyenv-win --target %USERPROFILE%\\.pyenv --no-user --upgrade`

steps to [add System Settings](#add-system-settings)

_Note:_ Don't forget the check above link, it contains final steps to complete.

Installation is complete!

***

#### **Chocolatey**

This needs choco commands to install, [installation link](https://chocolatey.org/install)

Chocolatey command `choco install pyenv-win`

Chocolatey page: [pyenv-win](https://chocolatey.org/packages/pyenv-win)

Installation is complete!

Validate Installation

***

#### **Add System Settings**

It's a easy way to use PowerShell here

1. Adding PYENV, PYENV_HOME and PYENV_ROOT to your Environment Variables

```pwsh
[System.Environment]::SetEnvironmentVariable('PYENV',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")

[System.Environment]::SetEnvironmentVariable('PYENV_ROOT',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")

[System.Environment]::SetEnvironmentVariable('PYENV_HOME',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
```

2. Now adding the following paths to your USER PATH variable in order to access the pyenv command

```pwsh
[System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv\pyenv-win\bin;" + $env:USERPROFILE + "\.pyenv\pyenv-win\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")
```

Installation is done. Hurray!

***

#### **How to use 32-train**

**Using Git**

1. For 32-train prerequisite is [installing pyenv-win using Git](#git-commands)
2. Go to .pyenv dir command `cd %USERPROFILE%\.pyenv`
3. run `git checkout -b 32bit-train origin/32bit-train`
4. run `pyenv --version` and you should see *2.32.x*

**Using pip**

1. run `pip install pyenv-win==2.32.x --target %USERPROFILE%\.pyenv`

2. steps to [add System Settings](#add-system-settings)

**Using Zip**

1. Download [pyenv-win.zip](https://github.com/pyenv-win/pyenv-win/archive/32bit-train.zip)

2. Follow step 2 from [Pyenv-win zip](#pyenv-win-zip)

3. steps to [add System Settings](#add-system-settings)

***

### Validate

1. Reopen the command prompt and run `pyenv --version`
2. Now type `pyenv` to view it's usage

If you are getting "**command not found**" error, check the below note and [manually check the settings](#manually-check-the-settings)

For Visual Studio Code or another IDE with a built in terminal, restart it and check again  

***

### Manually check the settings

Ensure all environment variables are properly set via the GUI: 

```
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
==================  
To keep in sync with [pyenv][1] linux/mac, pyenv-win now installs 64bit versions by default. To support compatibility with older versions of pyenv-win, we maintain a 32bit train (branch) as a separate release. 

Both releases can install 64bit and 32bit python versions; the difference is in version names, for example: 

* 64bit-train (master), i.e. pyenv version _2.64.x_

```
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

* 32bit-train, i.e. pyenv version _2.32.x_
```
>pyenv install -l | findstr 3.8
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
==================  
Support for Python versions below 2.4 have been dropped since their installers don't install "cleanly" like versions from 2.4 onward and they're predominantly out of use/support in most environments now.

==================  

## FAQ

- **Question:** Does pyenv for windows support python2?
   - **Answer:** Yes, We support python2 from version 2.4+ until python.org officially removes it.
   - Versions below 2.4 use outdated Wise installers and have issues installing multiple patch versions, unlike Windows MSI and the new Python3 installers that support "extraction" installations.

- **Question:** Does pyenv for windows support python3?
   - **Answer:** Yes, we support python3 from version 3.0. We support it from 3.0 until python.org officially removes it.

- **Question:** I am getting the issue `batch file cannot be found.` while installing python, what should I do?
   - **Answer:** You can ignore it. It's just calling `pyenv rehash` command before creating the bat file on some devices.

- **Question:** System is stuck while uninstalling a python version
   - **Answer:** Navigate to the location where you installed pyenv, open its 'versions' folder (usually `%USERPROFILE%\.pyenv\pyenv-win\versions`), and delete the folder of the version you want removed.

- **Question:** I installed pyenv-win using pip. How can I uninstall it?
   - **Answer:** Follow the pip instructions in [How to update pyenv](#how-to-update-pyenv) and then run `pip uninstall pyenv-win`

- **Question:** pyenv-win is not recognised, but I have set the ENV PATH?
   - **Answer:** According to Windows, when adding a path under the User variable you need to logout and login again, in order to reflect any change. For the System variable it's not required.

## Change Log

### New in 3.1.1

- Fix [#413](https://github.com/pyenv-win/pyenv-win/issues/413): bug: pyenv install failing because the system cannot find the file specified 'dark.exe'
- Adding: python 3.8, 3.9 and 3.10 in classifiers

### New in 3.1
- Fix [#142](https://github.com/pyenv-win/pyenv-win/issues/142): Prefer the local installer over the web based installer
- Fix [#401](https://github.com/pyenv-win/pyenv-win/issues/401), [#396](https://github.com/pyenv-win/pyenv-win/issues/396), [#383](https://github.com/pyenv-win/pyenv-win/issues/383) and [#360](https://github.com/pyenv-win/pyenv-win/issues/360): Added the same level of support for local based installer as we have for web based installers in [#410](https://github.com/pyenv-win/pyenv-win/issues/410)
  - **Note:** It is best to uninstall affected versions (3.9.11 and above) via Windows' `Add or remove Programs` systems settings page before running the `pyenv uninstall` command for those versions.

### New in 3.0
- Fix [#311](https://github.com/pyenv-win/pyenv-win/issues/311): Support many global and shell versions.
- Fix [#318](https://github.com/pyenv-win/pyenv-win/issues/318): `pyenv global` and `pyenv local` no longer affect PYENV_VERSION, which only `pyenv shell` should affect.
- The test suite emulates a 32 bit architecture environment.
- The test suite now also runs tests using `powershell` and `pwsh` in addition to `cmd`.
- `pyenv shell` now works like `pyenv global` and `pyenv local` in that, on 32-bit platforms, it adds `-win32` to every supplied version if not explicitly added.

### New in 2.64.11
- Fix [#287](https://github.com/pyenv-win/pyenv-win/issues/287): Prevent infinite recursion by removing the shims directory from the path.
- Fix [#259](https://github.com/pyenv-win/pyenv-win/issues/259): Correctly handle spaces in `pyenv` path.
- Fix [#305](https://github.com/pyenv-win/pyenv-win/issues/305): Fix `exec` preferring the last version listed in `.python-version` instead of the first.
  - **Note:** `pyenv rehash` must be called after upgrading. Expect the following error message if you don't:
    ```
    'Scripts' is not recognized as an internal or external command,
    operable program or batch file.
    ```

### New in 2.64.10
- Check `PATH` in `pyenv version` to report other Python versions.

### New in 2.64.9
- Feature [#210](https://github.com/pyenv-win/pyenv-win/issues/210): Support extended installer options
- Fix [#269](https://github.com/pyenv-win/pyenv-win/issues/269): Migration from travis-ci to GitHub Actions
- Fix `exec` shims for `bat` files.
- Fix [#193](https://github.com/pyenv-win/pyenv-win/issues/193): PowerShell support for `pyenv shell`

### New in 2.64.8
- Fix [#198](https://github.com/pyenv-win/pyenv-win/issues/198): [PEP 514](https://www.python.org/dev/peps/pep-0514/) support (64 bits only, excluding pypy).

### New in 2.64.7.4
- Fix [#256](https://github.com/pyenv-win/pyenv-win/issues/256): Fix `pyenv --version` for username with space.

### New in 2.64.7.3
- Fix [#254](https://github.com/pyenv-win/pyenv-win/issues/254): Fix exec with many local versions.

### New in 2.64.7.2
- Fix [#250](https://github.com/pyenv-win/pyenv-win/issues/250): PATH is not impacted after a `pyenv exec`.

### New in 2.64.7.1
- Fix [#246](https://github.com/pyenv-win/pyenv-win/issues/246): `pyenv which` and `pyenv whence` show help if no argument specified.
- Fix exec problems after merge of [#140](https://github.com/pyenv-win/pyenv-win/pull/140).
- Fix [#247](https://github.com/pyenv-win/pyenv-win/pull/247): no more incorrect file name in bash script if username contains a space.
- Fix [#243](https://github.com/pyenv-win/pyenv-win/issues/243): hot fix for `pyenv exec`.

### New in 2.64.6.1
- Use GitHub Actions to publish to PyPi.

### New in 2.64.5
- Fix [#239](https://github.com/pyenv-win/pyenv-win/issues/239): Improve `rehash` error when no version installed.
- Add pypy support.
- Fix [#140](https://github.com/pyenv-win/pyenv-win/pull/140): Get rid of temp `exec.bat` to support multiple exec in parallel.

### New in 2.64.4
- More python versions supported.
- Fix [#217](https://github.com/pyenv-win/pyenv-win/pull/217): Add missing call to `exec.bat`.
- Enhancement [#225](https://github.com/pyenv-win/pyenv-win/pull/217): Add tox support.
- Fix [#204](https://github.com/pyenv-win/pyenv-win/issues/239): Support many local versions.
- Enhancement [#220](https://github.com/pyenv-win/pyenv-win/issues/220): Rehash all installed versions with more shims.
- Enhancement [#221](https://github.com/pyenv-win/pyenv-win/pull/221): Add `pyenv global --unset`.

### New in 2.64.3
- Version naming conventions have now changed from using 64-bit suffixes when specifying a version to (un)install. Now all you need to use is the version number to install your platform's specific bit version.
   - **\*WARNING\*: This change is backwards incompatible with v1.2.5 or less; if upgrading from that version, install [32bit-train](#32bit-train-support) which is backward compatible, or uninstall all versions of python prior to upgrading pyenv.**
   - Ex. `pyenv install 2.7.17` will install as 64-bit on x64 and 32-bit on x86. (64-bit can still use `2.7.17-win32` to install the 32-bit version)
   - `pyenv global/local/shell` also now recognize your platform and select the appropriate bit version. (64-bit users will need to specify `[version]-win32` to use the 32-bit versions now)
- Added support for true unobtrusive, local installs.
  - **\*WARNING\*: This change is backwards incompatible with v1.2.5 or less; if upgrading from that version, install [32bit-train](#32bit-train-support) which is backward compatible, or uninstall all versions of python prior to upgrading pyenv.**
  - No install/uninstall records are written to the registry or Start Menu anymore (no "Programs and Features" records).
  - When installing a patch version of python (ex. 3.6.1) installing another patch version (ex. 3.6.2) won't reuse the same folder and overwrite the previously installed minor version. They're now kept separate.
  - Uninstalls are now a simple folder deletion. (Can be done manually by the user safely now or `pyenv uninstall`)
- Added support for (un)installing multiple versions of python in a single command or all DB versions via the `-a/--all` switch.
   - When using `--all` on x64 computers you can use `--32only` or `--64only` to install only 32-bit or only 64-bit version s of python. (Does nothing on 32-bit computers, and better filters may be in the works later on)
- `pyenv global/rehash` is called automatically after (un)installing a new Python version. (last version specified, if installing multiple)
- Pyenv now uses a cached DB of versions scraped straight from the Python mirror site and can be updated manually by a user using `pyenv update`. Users no longer have to wait for pyenv's source repo to be updated to use a new version of Python when it releases, and can also use the new alpha/beta python releases.
- `pyenv install` now has a `-c/--clear` to empty cached installers in the `%PYENV%\install_cache` folder.
- `pyenv rehash` now acknowledges %PATHEXT% (plus PY and PYW) when creating shims instead of just for exe, bat, cmd and py files so more executables are available from `\Scripts` and libraries installed using pip.
- Shims created using `pyenv rehash` no longer call `pyenv exec`, but instead call python directly to prevent issues with other programs executing the shims.
- Shims now use cp1250 as the default code page since Python2 will [never actually support cp65001](https://bugs.python.org/issue6058#msg120712). cp1250 has better support for upper ANSI characters (ex. "Pokémon"), but still isn't full UTF-8 compatible.
- **Note: Support for Python versions below 2.4 have been dropped since their installers don't install "cleanly" like versions from 2.4 onward and they're predominantly out of use/support in most environments now.**

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

- pyenv-win is licensed under [MIT](http://opensource.org/licenses/mit-license.php) *2019*

   [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Author and Thanks

pyenv-win was developed by [Kiran Kumar Kotari](https://github.com/kirankotari) and [Contributors](https://github.com/pyenv-win/pyenv-win/graphs/contributors)  
Thanks for all Contributors and Supports for patience for the latest major release.

[1]: https://github.com/pyenv/pyenv
[2]: https://github.com/rbenv/rbenv
[3]: https://github.com/nak1114/rbenv-win
[4]: https://github.com/pyenv/pyenv/issues/62
[5]: https://github.com/pyenv-win/pyenv-win
