# pyenv for Windows

[pyenv][1] 是一个伟大的工具。我已经移植到了Windows。还有一些命令没有实现，但它足以满足基本的使用。

对于已经安装了python的用户，我们支持从pip安装： [follow instructions](#installation)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues open](https://img.shields.io/github/issues/pyenv-win/pyenv-win.svg?)](https://github.com/pyenv-win/pyenv-win/issues)
[![Downloads](https://pepy.tech/badge/pyenv-win)](https://pepy.tech/project/pyenv-win)

- [介绍](#introduction)
- [pyenv](#pyenv)
- [pyenv-win 命令](#pyenv-win-commands)
- [安装](#installation)
   - [获取pyenv-win](#get-pyenv-win)
   - [安装完成](#finish-the-installation)
- [使用](#usage)
- [如何获取更新](#how-to-get-updates)
- [FAQ](#faq)
- [How to contribute](#how-to-contribute)
- [Bug Tracker and Support](#bug-tracker-and-support)
- [License and Copyright](#license-and-copyright)
- [Author and Thanks](#author-and-thanks)

## 介绍

[pyenv][1] 是python中一个伟大的工具， 像ruby开发人员使用的 [rbenv][2] 一样, 它不直接支持Windows. 经过一些python开发人员的研究与反馈后, 我发现他们像要一个可以在Windows上运行的类似工具。

我从这个pyenv的[issue][4]获得支持Windows的启发。就我个人而言，我使用Mach和Linux的[pyenv][1]是完美的，但一些公司仍然使用Windows开发。这个类库用来帮助Windows用户管理多个pyton版本。

我发现一个ruby开发者使用的类似系统 [rbenv-win][3] 。这个项目是从[rbenv-win][3] forked并修改为[pyenv][1]。一些命令没有实现，但它足以满足基本的使用。

## pyenv

[pyenv][1]是一个简单的python版本管理工具。它让我你能容易的在多个python版本之间切换。它是简单的、不显眼的、并遵循UNIX传统的单一用途的工具，它能很好的完成这件事。

## pyenv-win 命令

```yml
   commands    列累出所有可以验证的pyenv命令
   local       设置或显示特定于本地应用程序的 Python 版本
   global      设置活显示全局 Python 版本
   shell       设置或显示特定shell外壳的 Python 版本
   install     使用 Python 生成安装 Python 版本
   uninstall   卸载一个特定的 Python 版本
   rehash      重新生成 pyenv shims 目录的快捷方式 (安装可执行文件后运行此命令)
   version     显示当前 Python 版本及其来源
   versions    列出 pyenv 可用的所有 Python 版本
   exec        使用PATH中设置的第一个Python程序运行一个可执行文件
```

## 安装

### 获取pyenv-win

通过以下方式之一获取python-win。 (注意: 例子实在命令行中执行的. 对于Powershell, 替换 `%USERPROFILE%` 为 `$env:USERPROFILE`. 对于 Git Bash, 替换为 `$HOME`.)

- 通过pip** (支持从已安装python的用户)
   - `pip install pyenv-win --target %USERPROFILE%/.pyenv`
- **通过 zip 文件**
   1. 下载连接: [pyenv-win](https://github.com/pyenv-win/pyenv-win/archive/master.zip)
   2. 提取到 `%USERPROFILE%/.pyenv/pyenv-win` 目录
- **通过 Git**
   - `git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%/.pyenv`

### 安装完成

   1. 添加下来路径到你的环境变量PATH中(别忘了用分号分隔):
      - `%USERPROFILE%\.pyenv\pyenv-win\bin`
      - `%USERPROFILE%\.pyenv\pyenv-win\shims`
      - 环境变量打开方式 :: 此电脑（右键） -> 属性 -> 高级系统设置 -> 高级-> 环境变量 -> 系统变量的path
      - _小心! People who uses Windows (>= May 2019 Update) must put these items above `%USERPROFILE%\AppData\Local\Microsoft\WindowsApps`; See [this article](https://devblogs.microsoft.com/python/python-in-the-windows-10-may-2019-update/)._
   2. 打开一个新的命令窗口使用 `pyenv --version` 验证是否成功
   3. 现在运行 `pyenv rehash` 
      - 你应该看到 [当前的 pyenv 版本](https://github.com/pyenv-win/pyenv-win/blob/master/setup.py). 如果收到错误，则再次执行这些步骤。仍然面临这个问题？ [Open a ticket](https://github.com/pyenv-win/pyenv-win/issues).
   4. 运行`pyenv` 查看它支持的命令列表。 [More info...](#usage)

   安装已完成。Hurray!

## 使用

- 查看pyenv支持的python版本: `pyenv install -l`
- 安装指定的python版本:  `pyenv install 3.5.2`
   
   - _注意: 旧版本的python是mis格式的文件。 在安装过程中，您需要单击向导。_
   
     _无需更改其中的任何选项。
- 设置一个全局python版本: `pyenv global 3.5.2`
   - 如果本地版本(看下文)没有被设置将使用这个python版本作为默认版本。
   - _注意: 这个版本必须先安装_
- 设置本地版本: `pyenv local 3.5.2`.
   - 每当从当前文件夹调用 `python` 时将使用该命令给定的版本. 这与一个与你环境时不同的, 需要显式激活。
   - _注意: 这个版本必须先安装_
- 之后无论你安装/卸载python, 你必须运行 `pyenv rehash` 去更新pyenv的python版本（也就是shim文件夹的内容）
   
   - _注意: 这个命令 必须在`.pyenv` 文件夹只外运行_
- 卸载一个python版本: `pyenv uninstall 3.5.2`
- 查看你正在使用的python版本和路径: `pyenv version`
- 查看你已经安装的python版本: `pyenv versions`

## 如何获取更新

- 如果是通过 pip 安装的
   - 添加 pyenv-win 的安装路径到 `easy_install.pth` 文件中，这个文件在  site-package文件夹中。 现pyenv-win可以被点识别了。
   - 从pip命令获取更新 `pip install --upgrade pyenv-win`
- 如果是通过git安装的
   - 到 `%USERPROFILE%/.pyenv/pyenv-win` 目录(你的pyenv-win安装目录) 并运行 `git pull`
- 如果是通过zip文件安装的
   - 下载最终版zip文件并解压
   - 到 `%USERPROFILE%/.pyenv/pyenv-win/` 目录刚用解压的文件替换 `libexec` 目录和 `bin` 

## FAQ

- **Question:** Does pyenv for windows support python2?
   - **Answer:** Yes, We support python2 from version 2.0.1. We support it from 2.0.1 until python.org officially removes it.

- **Question:** Does pyenv for windows support python3?
   - **Answer:** Yes, we support python3 from version 3.0. We support it from 3.0 until python.org officially removes it.

- **Question:** I am getting the issue `batch file cannot be found.` while installing python, what should I do?
   - **Answer:** You can ignore it. It's calling `pyenv rehash` command before creating the bat file in few devices.

- **Question:** System is stuck while uninstalling the python version, what to do?
   - **Answer:** It's based on the system policies in some computers, recommend to uninstall in these computers by going to the path `%USERPROFILE%/.pyenv/pyenv-win/install_cache/`. I believe you know manual uninstallation. Please remove the `site-package` and `scripts` while uninstalling (mandatory). Double check the python version folder doesn't exist in the path `%USERPROFILE%/.pyenv/pyenv-win/versions/` if exist please do remove it (mandatory).

- **Question:** I installed pyenv-win using pip. How can I uninstall it?
   - **Answer:** Follow the pip instructions in [How to get updates](#how-to-get-updates) and then run `pip uninstall pyenv-win`

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

pyenv-win was developed by [Kiran Kumar Kotari](https://github.com/kirankotari) and [Contributors](https://github.com/pyenv-win/pyenv-win/graphs/contributors)

[1]: https://github.com/pyenv/pyenv
[2]: https://github.com/rbenv/rbenv
[3]: https://github.com/nak1114/rbenv-win
[4]: https://github.com/pyenv/pyenv/issues/62
