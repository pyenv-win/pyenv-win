# FAQ

- **Question:** python --version is showing different version than expected?
  - **Answer:** Check your **Environment Variables** where pyenv path need to be in priority. You can manually move them up, save it and restart your prompt (cmd/powershell/git-bash/etc)

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
  - **Answer:** Follow the pip instructions in [How to update pyenv](../README.md#how-to-update-pyenv) and then run `pip uninstall pyenv-win`

- **Question:** pyenv-win is not recognised, but I have set the ENV PATH?
  - **Answer:** According to Windows, when adding a path under the User variable you need to logout and login again, in order to reflect any change. For the System variable it's not required.

  **Question:** How do I configure my company proxy in pyenv for windows?
  - **Answer:** Set the `http_proxy` or `https_proxy` environment variable with the hostname or IP address of the proxy server in URL format, for example: `http://username:password@hostname:port/` or `http://hostname:port/`
