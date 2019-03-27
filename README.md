# pyenv for Windows

The [pyenv][1] is a great tool. I ported it to Windows. Some commands doesn't implemented, but wouldn't be a problem in basic use.

For existing python users, we are supporting installation via pip [follow instructions](#installation)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues open](https://img.shields.io/github/issues/pyenv-win/pyenv-win.svg?)](https://github.com/pyenv-win/pyenv-win/issues)
[![Downloads](https://pepy.tech/badge/pyenv-win)](https://pepy.tech/project/pyenv-win)

- [Introduction](#introduction)
- [pyenv](#pyenv)
- [pyenv-win does](#pyenv-win-does)
- [Installation](#installation)
- [How it works](#how-it-works)
- [How to get updates](#how-to-get-updates)
- [FAQ](#faq)
- [How to contribute](#how-to-contribute)
- [Bug Tracker and Support](#bug-tracker-and-support)
- [License and Copyright](#license-and-copyright)
- [Author and Thanks](#author-and-thanks)

## Introduction

The [pyenv][1] for python is a great tool, but it doesn't supports windows platform directly, which was the same case in [rbenv][2] for ruby developers. After a bit of research and feedbacks from python developers, they loves to have such a feature for windows systems.

I got inspired from the pyenv [issues][4] for windows support, personally I too use Mac and Linux with beautiful [pyenv][1], but in some companies they still use windows for their development. This library is to help windows users to manage multiple pythons.

Found a similar system for [rbenv-win][3] for ruby developers. This project was forked from [rbenv-win][3] and modified for [pyenv][1]. Some commands doesn't implemented, but wouldn't be a problem in basic use.

## pyenv

[pyenv][1] is a simple python version management tool. It lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

## pyenv-win does

```yml
   commands    List all available pyenv commands
   local       Set or show the local application-specific Python version
   global      Set or show the global Python version
   shell       Set or show the shell-specific Python version
   install     Install a Python version using python-build
   uninstall   Uninstall a specific Python version
   rehash      Rehash pyenv shims (run this after installing executables)
   version     Show the current Python version and its origin
   versions    List all Python versions available to pyenv
   exec        Runs an executable by first preparing PATH so that the selected Python
```

## Installation

- **Installing by pip:** (To support existing python users)

   1. For command prompt use following command `pip install pyenv-win --target %USERPROFILE%/.pyenv` (or)  
For git bash or alternative use following command `pip install pyenv-win --target $HOME/.pyenv`
   2. Add the following paths to your ENVIRONMENT PATH variable for accessing to pyenv command
`%USERPROFILE%\.pyenv\pyenv-win\bin;%USERPROFILE%\.pyenv\pyenv-win\shims;` at the beginning
      - __ENVIRONMENT PATH :: My Computer -> properties -> Advanced system settings -> Advanced -> Environment Variables -> PATH__
   3. Open command prompt (new session) and type `pyenv --version`
   4. You need to see current pyenv version. If you are getting an error go through the steps again still facing the issue [open a ticket](https://github.com/pyenv-win/pyenv-win/issues).
   5. Type `pyenv` to see list of commands it support. [More..](#how-it-works)

   Installation is done hurray...!

- **Installing by downloading zip file:**

   1. Link: [pyenv-win](https://github.com/pyenv-win/pyenv-win/archive/master.zip)
   2. Extract to your `%USERPROFILE%/.pyenv/pyenv-win`
   3. Add the following paths to your ENVIRONMENT PATH variable for accessing to pyenv command
`%USERPROFILE%\.pyenv\pyenv-win\bin;%USERPROFILE%\.pyenv\pyenv-win\shims;` at the beginning
       - __ENVIRONMENT PATH :: My Computer -> properties -> Advanced system settings -> Advanced -> Environment Variables -> PATH__

   4. Open command prompt (new session) and type `pyenv --version`
   5. You need to see current pyenv version. If you are getting an error go through the steps again still facing the issue [open a ticket](https://github.com/pyenv-win/pyenv-win/issues).
   6. Type `pyenv` to see list of commands it support. [More..](#how-it-works)

   Installation is done hurray...!

- **Installing by git:**

   1. Clone the repository to the user profile  
`git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%/.pyenv/pyenv-win`
   2. Add the following paths to your ENVIRONMENT PATH variable for accessing to pyenv command
`%USERPROFILE%\.pyenv\pyenv-win\bin;%USERPROFILE%\.pyenv\pyenv-win\shims;` at the beginning
       - __ENVIRONMENT PATH :: My Computer -> properties -> Advanced system settings -> Advanced -> Environment Variables -> PATH__

   3. Open command prompt (new session) and type `pyenv --version`
   4. You need to see current pyenv version. If you are getting an error go through the steps again still facing the issue [open a ticket](https://github.com/pyenv-win/pyenv-win/issues).
   5. Type `pyenv` to see list of commands it support. [More..](#how-it-works)

   Installation is done hurray...!

## How it works

- To view list of python versions supported by pyenv windows. `pyenv install -l`
- To install python version.  `pyenv install 3.5.2` _Note: older version of python is msi file just click on next to install (no need of changing any options it in)_
- To set a python version as global version. `pyenv global 3.5.2` _Note: version needs to be installed_
- To set a python version as local version. `pyenv local 3.5.2` you can give any version which you wanted to use to the project, this will be auto activated by entering to the folder not like other virtual env. to activate.
- To uninstall any python version. `pyenv uninstall 3.5.2`
- To know which python you are using and its path `pyenv version`
- To view all the python versions installed in this system `pyenv versions`

## How to get updates

- Installed via pip
   - Add pyenv-win installed path to `easy_install.pth` file which is located in site-package. Now pyenv-win is recognised by pip 
   - Get updates via pip `pip install --upgrade pyenv-win`
- Installed via git
   - Go to the `%USERPROFILE%/.pyenv/pyenv-win` (which is your installed path) and type `git pull`
- Installed via zip
   - Go to the path `%USERPROFILE$/.pyenv/pyenv-win/` replace `libexec` and `bin` folder 

## FAQ

- **Question:** Does pyenv for windows support python2?  
 **Answer:** Yes, We are supporting python2 from the version 2.0.1. We are supporting from 2.0.1 until the python.org officially removes.

- **Question:** Does pyenv for windows support python3?  
 **Answer:** Yes, we are supporting python3 from the version 3.0. We are supporting from 3.0 until the python.org officially removes.

- **Question:** I am getting an issue `batch file cannot be found.` while installing python, what to do?  
  **Answer:** You can ignore it. It's calling `pyenv rehash` command before creating the bat file in few devices.

- **Question:** System is stuck while uninstalling the python version, what to do?  
  **Answer:** It's based on the system policies in few computers, recommend to uninstall in these computers by going to the path `%USERPROFILE%/.pyenv/pyenv-win/install_cache/`. I believe you know manual uninstallation. Please remove the `site-package` and `scripts` while uninstalling (mandatory). Double check the python version folder doesn't exist in the path `%USERPROFILE%/.pyenv/pyenv-win/versions/` if exist please do remove it (mandatory).

- **Question:** I installed pyenv-win using pip how to uninstall it?  
  **Answer:** Follow How to get updates in pip [link](#how-to-get-updates) and then `pip uninstall pyenv-win`

## How to contribute

- Fork the project & clone locally.
- Create an upstream remote and sync your local copy before you branch.
- Branch for each separate piece of work. It's a good practise to write test cases.
- Do the work, write good commit messages, and read the CONTRIBUTING file if there is one.
- Test the changes by running `tests\test_install.bat` and `tests\test_uninstall.bat`
- Push to your origin repository.
- Create a new Pull Request in GitHub.

## Bug Tracker and Support

- Please report any suggestions, bug reports, or annoyances with pyenv-win through the [GitHub bug tracker](https://github.com/pyenv-win/pyenv-win/issues).

## License and Copyright

- pyenv-win is licensed under [MIT](http://opensource.org/licenses/mit-license.php) *2019*

   [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Author and Thanks

pyenv-win was developed by [Kiran Kumar Kotari](https://github.com/kirankotari)

[1]: https://github.com/pyenv/pyenv
[2]: https://github.com/rbenv/rbenv
[3]: https://github.com/nak1114/rbenv-win
[4]: https://github.com/pyenv/pyenv/issues/62
