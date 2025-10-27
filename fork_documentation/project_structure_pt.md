## Indice de versoes e fluxo de isntalacao

- Base local de versoes: `pyenv-win/.versions_cache.xml`
- Script de update: `pyenv-win/libexec/pyenv-update.vbs`
  - Faz parsing do FTP do python.org com regex (sem DOM)
  - Suporta subpastas: `amd64/`, `arm64/`, `win32`
  - Remove: rc, alpha, beta, pypy, graalpy
  - Mantem apenas CPython estavel
- Script de instalacao: `pyenv-win/libexec/pyenv-install.vbs`
  - Usa WiX dark.exe para extrair quando necessario
  - Roda ensurepip quando preciso
- Selecao de arquitetura: `pyenv-win/libexec/libs/pyenv-lib.vbs`
  - Em x64 padrao e amd64 (sem sufixo)
  - Para ARM64 use `-arm64`
- Update apos instalacao:
  - `pyenv-win/install-pyenv-win.ps1` atualiza o cache apos instalar
