# Installation

Currently we support following ways, choose any of your comfort:

- [PowerShell](#powershell) - easiest way
- [Git Commands](#git-commands) - default way + adding manual settings
- [Pyenv-win zip](#pyenv-win-zip) - manual installation
- [Python pip](#python-pip) - for existing users
- [Chocolatey](#chocolatey)
- [How to use 32-train](#how-to-use-32-train)  
  - [check announcements](../README.md#announcements)

Hurray! When you are done here are steps to [Validate installation](../README.md#validate-installation)

_NOTE:_ If you are running Windows 10 1905 or newer, you might need to disable the built-in Python launcher via Start > "Manage App Execution Aliases" and turning off the "App Installer" aliases for Python

***

## **PowerShell**

The easiest way to install pyenv-win is to run the following installation command in a PowerShell terminal:

```pwsh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

If you are getting any **UnauthorizedAccess** error as below then start Windows PowerShell with the "Run as administrator" option and run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine`, now re-run the above installation command.

```plaintext
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

[Return to README](../README.md#installation)

***

## **Git Commands**

The default way to install pyenv-win, it needs git commands you need to install git/git-bash for windows

If you are using PowerShell or Git Bash use `$HOME` instead of `%USERPROFILE%`

git clone using command prompt `git clone https://github.com/pyenv-win/pyenv-win.git "%USERPROFILE%\.pyenv"`

steps to [add System Settings](#add-system-settings)

_Note:_ Don't forget the check above link, it contains final steps to complete.

Installation is complete!

[Return to README](../README.md#installation)

***

## **Pyenv-win zip**

Manual installation steps for pyenv-win

If you are using PowerShell or Git Bash use `$HOME` instead of `%USERPROFILE%`

1. Download [pyenv-win.zip](https://github.com/pyenv-win/pyenv-win/archive/master.zip)

2. Create a `.pyenv` directory using command prompt `mkdir %USERPROFILE%/.pyenv` if not exist

3. Extract and move files to `%USERPROFILE%\.pyenv\`

4. Ensure there is a `bin` folder under `%USERPROFILE%\.pyenv\pyenv-win`

steps to [add System Settings](#add-system-settings)

_Note:_ Don't forget the check above link, it contains final steps to complete.

Installation is complete!

Return to [README](../README.md#installation)

***

## **Python pip**

For existing python users

### Command prompt

`pip install pyenv-win --target %USERPROFILE%\\.pyenv`  

If you run into an error with the above command use the folllowing instead ([#303](https://github.com/pyenv-win/pyenv-win/issues/303)):

`pip install pyenv-win --target %USERPROFILE%\\.pyenv --no-user --upgrade`

### PowerShell or Git Bash

Use the same command as above, but replace `%USERPROFILE%` with `$HOME`.

### Final steps

Proceed to [adding System Settings](#add-system-settings).

Installation should then be complete!

Return to [README](../README.md#installation)

***

## **Chocolatey**

This needs choco commands to install, [installation link](https://chocolatey.org/install)

Chocolatey command `choco install pyenv-win`

Chocolatey page: [pyenv-win](https://chocolatey.org/packages/pyenv-win)

Installation is complete!

Validate Installation

Return to [README](../README.md#installation)

***

## **Add System Settings**

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

If for some reason you cannot execute PowerShell command(likely on an organization managed device), type "environment variables for you account" in Windows search bar and open Environment Variables dialog.
You will need create those 3 new variables in System Variables section (bottom half). Let's assume username is `my_pc`.
|Variable|Value|
|---|---|
|PYENV|C:\Users\my_pc\\.pyenv\pyenv-win\
|PYENV_HOME|C:\Users\my_pc\\.pyenv\pyenv-win\
|PYENV_ROOT|C:\Users\my_pc\\.pyenv\pyenv-win\

And add two more lines to user variable `Path`.
```
C:\Users\my_pc\.pyenv\pyenv-win\bin
C:\Users\my_pc\.pyenv\pyenv-win\shims
```

Installation is done. Hurray!
Return to [README](../README.md#installation)

## **Usage with Git BASH**

From within Git BASH, run the following:

```sh
echo 'export PATH="$HOME/.pyenv/pyenv-win/shims:$PATH"' >> ~/.bash_profile
echo 'export PATH="$HOME/.pyenv/pyenv-win/bin:$PATH"' >> ~/.bash_profile
```

Open a new terminal, and confirm `pyenv --version` works.

***

## **How to use 32-train**

- **Using Git**
  1. For 32-train prerequisite is [installing pyenv-win using Git](#git-commands)
  2. Go to .pyenv dir command `cd %USERPROFILE%\.pyenv`
  3. run `git checkout -b 32bit-train origin/32bit-train`
  4. run `pyenv --version` and you should see _2.32.x_
- **Using pip**
  1. run `pip install pyenv-win==2.32.x --target %USERPROFILE%\.pyenv`
  2. steps to [add System Settings](#add-system-settings)
- **Using Zip**
  1. Download [pyenv-win.zip](https://github.com/pyenv-win/pyenv-win/archive/32bit-train.zip)
  2. Follow step 2 from [Pyenv-win zip](#pyenv-win-zip)
  3. steps to [add System Settings](#add-system-settings)

Return to [README](../README.md#installation)
