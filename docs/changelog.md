# Changelog

## New in 3.1.1

- Fix [#413](https://github.com/pyenv-win/pyenv-win/issues/413): bug: pyenv install failing because the system cannot find the file specified 'dark.exe'
- Adding: python 3.8, 3.9 and 3.10 in classifiers

## New in 3.1

- Fix [#142](https://github.com/pyenv-win/pyenv-win/issues/142): Prefer the local installer over the web based installer
- Fix [#401](https://github.com/pyenv-win/pyenv-win/issues/401), [#396](https://github.com/pyenv-win/pyenv-win/issues/396), [#383](https://github.com/pyenv-win/pyenv-win/issues/383) and [#360](https://github.com/pyenv-win/pyenv-win/issues/360): Added the same level of support for local based installer as we have for web based installers in [#410](https://github.com/pyenv-win/pyenv-win/issues/410)
  - **Note:** It is best to uninstall affected versions (3.9.11 and above) via Windows' `Add or remove Programs` systems settings page before running the `pyenv uninstall` command for those versions.

## New in 3.0

- Fix [#311](https://github.com/pyenv-win/pyenv-win/issues/311): Support many global and shell versions.
- Fix [#318](https://github.com/pyenv-win/pyenv-win/issues/318): `pyenv global` and `pyenv local` no longer affect PYENV_VERSION, which only `pyenv shell` should affect.
- The test suite emulates a 32 bit architecture environment.
- The test suite now also runs tests using `powershell` and `pwsh` in addition to `cmd`.
- `pyenv shell` now works like `pyenv global` and `pyenv local` in that, on 32-bit platforms, it adds `-win32` to every supplied version if not explicitly added.

## New in 2.64.11

- Fix [#287](https://github.com/pyenv-win/pyenv-win/issues/287): Prevent infinite recursion by removing the shims directory from the path.
- Fix [#259](https://github.com/pyenv-win/pyenv-win/issues/259): Correctly handle spaces in `pyenv` path.
- Fix [#305](https://github.com/pyenv-win/pyenv-win/issues/305): Fix `exec` preferring the last version listed in `.python-version` instead of the first.
  - **Note:** `pyenv rehash` must be called after upgrading. Expect the following error message if you don't:

    ```plaintext
    'Scripts' is not recognized as an internal or external command,
    operable program or batch file.
    ```

## New in 2.64.10

- Check `PATH` in `pyenv version` to report other Python versions.

## New in 2.64.9

- Feature [#210](https://github.com/pyenv-win/pyenv-win/issues/210): Support extended installer options
- Fix [#269](https://github.com/pyenv-win/pyenv-win/issues/269): Migration from travis-ci to GitHub Actions
- Fix `exec` shims for `bat` files.
- Fix [#193](https://github.com/pyenv-win/pyenv-win/issues/193): PowerShell support for `pyenv shell`

## New in 2.64.8

- Fix [#198](https://github.com/pyenv-win/pyenv-win/issues/198): [PEP 514](https://www.python.org/dev/peps/pep-0514/) support (64 bits only, excluding pypy).

## New in 2.64.7.4

- Fix [#256](https://github.com/pyenv-win/pyenv-win/issues/256): Fix `pyenv --version` for username with space.

## New in 2.64.7.3

- Fix [#254](https://github.com/pyenv-win/pyenv-win/issues/254): Fix exec with many local versions.

## New in 2.64.7.2

- Fix [#250](https://github.com/pyenv-win/pyenv-win/issues/250): PATH is not impacted after a `pyenv exec`.

## New in 2.64.7.1

- Fix [#246](https://github.com/pyenv-win/pyenv-win/issues/246): `pyenv which` and `pyenv whence` show help if no argument specified.
- Fix exec problems after merge of [#140](https://github.com/pyenv-win/pyenv-win/pull/140).
- Fix [#247](https://github.com/pyenv-win/pyenv-win/pull/247): no more incorrect file name in bash script if username contains a space.
- Fix [#243](https://github.com/pyenv-win/pyenv-win/issues/243): hot fix for `pyenv exec`.

## New in 2.64.6.1

- Use GitHub Actions to publish to PyPi.

## New in 2.64.5

- Fix [#239](https://github.com/pyenv-win/pyenv-win/issues/239): Improve `rehash` error when no version installed.
- Add pypy support.
- Fix [#140](https://github.com/pyenv-win/pyenv-win/pull/140): Get rid of temp `exec.bat` to support multiple exec in parallel.

## New in 2.64.4

- More python versions supported.
- Fix [#217](https://github.com/pyenv-win/pyenv-win/pull/217): Add missing call to `exec.bat`.
- Enhancement [#225](https://github.com/pyenv-win/pyenv-win/pull/217): Add tox support.
- Fix [#204](https://github.com/pyenv-win/pyenv-win/issues/239): Support many local versions.
- Enhancement [#220](https://github.com/pyenv-win/pyenv-win/issues/220): Rehash all installed versions with more shims.
- Enhancement [#221](https://github.com/pyenv-win/pyenv-win/pull/221): Add `pyenv global --unset`.

## New in 2.64.3

- Version naming conventions have now changed from using 64-bit suffixes when specifying a version to (un)install. Now all you need to use is the version number to install your platform's specific bit version.
  - **\*WARNING\*: This change is backwards incompatible with v1.2.5 or less; if upgrading from that version, install [32bit-train](installation.md#how-to-use-32-train) which is backward compatible, or uninstall all versions of python prior to upgrading pyenv.**
  - Ex. `pyenv install 2.7.17` will install as 64-bit on x64 and 32-bit on x86. (64-bit can still use `2.7.17-win32` to install the 32-bit version)
  - `pyenv global/local/shell` also now recognize your platform and select the appropriate bit version. (64-bit users will need to specify `[version]-win32` to use the 32-bit versions now)
- Added support for true unobtrusive, local installs.
  - **\*WARNING\*: This change is backwards incompatible with v1.2.5 or less; if upgrading from that version, install [32bit-train](installation.md#how-to-use-32-train) which is backward compatible, or uninstall all versions of python prior to upgrading pyenv.**
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
