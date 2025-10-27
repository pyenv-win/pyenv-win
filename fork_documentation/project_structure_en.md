## Version index and install flow

- Local version DB: `pyenv-win/.versions_cache.xml`
- Update script: `pyenv-win/libexec/pyenv-update.vbs`
  - Parses python.org FTP pages with regex (no DOM)
  - Supports subfolders: `amd64/`, `arm64/`, `win32`
  - Filters out: rc, alpha, beta, pypy, graalpy
  - Keeps CPython stable only
- Install script: `pyenv-win/libexec/pyenv-install.vbs`
  - Uses WiX dark.exe for exe extraction when needed
  - Runs ensurepip when required
- Arch selection: `pyenv-win/libexec/libs/pyenv-lib.vbs`
  - Default on x64 is amd64 (no suffix)
  - For ARM64 use `-arm64`
- Post install update:
  - `pyenv-win/install-pyenv-win.ps1` refreshes cache after install

