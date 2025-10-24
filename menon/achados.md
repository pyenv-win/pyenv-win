# Achados sobre atualização de versões no pyenv-win

- Base local de versões: `pyenv-win/.versions_cache.xml:1`
  - Contém mapeamentos de `<code>`, `<file>`, `<URL>` e atributos `x64`, `webInstall`, `msi`.
  - É gerado automaticamente por `pyenv update` e consumido por `pyenv install`.

- Coleta e geração da base:
  - Driver: `pyenv-win/libexec/pyenv-update.vbs:1`
  - Mirrors (fontes): `pyenv-win/libexec/libs/pyenv-install-lib.vbs:6`
    - Inclui `https://www.python.org/ftp/python` (Python oficial), `https://downloads.python.org/pypy/versions.json` (PyPy) e releases do GraalPy.
  - Parsing de arquivos: `pyenv-win/libexec/libs/pyenv-install-lib.vbs:33`
    - Regex aceita `python-<ver>[-amd64][-arm64][-webinstall].(exe|msi)`;
    - Preferência por instalador offline (remove `-webinstall` quando ambos existem).
  - Caminho do cache gerado: `pyenv-win/.versions_cache.xml:1` (sobrescrito pelo update).

- Instalação de versões:
  - Orquestrador: `pyenv-win/libexec/pyenv-install.vbs:1`
  - Para `.exe` (offline), extrai MSIs com WiX `dark.exe`: `pyenv-win/bin/WiX:1`
  - Para `.msi`, usa `msiexec /a` (instala em diretório alvo sem UI), e roda `ensurepip` se necessário.

- Resolução de arquitetura e nomes:
  - Arquitetura padrão: `pyenv-win/libexec/libs/pyenv-lib.vbs:195`
    - `AMD64` => sufixo vazio (amd64 é default em máquinas x64);
    - `ARM64` => sufixo `-arm64`;
    - `X86`   => sufixo `-win32`.
  - `pyenv latest` ignora pré-releases ao escolher estáveis: `pyenv-win/libexec/libs/pyenv-install-lib.vbs:329`.

- Conclusões práticas
  - O motor já suporta coletar Python moderno (3.8+ até 3.12/3.13), incluindo variantes `-amd64` e `-arm64` quando disponíveis, diretamente do FTP oficial.
  - O gargalo é a base antiga versionada no repo; rodar `pyenv update` renova o XML e libera as versões atuais.
  - Melhor UX: rodar `pyenv update` automaticamente após instalar/atualizar o pyenv-win.

- Mudanças propostas (curto prazo)
  - Invocar `pyenv update --ignore` no fim do `install-pyenv-win.ps1` para pré-popular a base.
  - Documentar como selecionar arquitetura: amd64 implícito em hosts x64; usar `-arm64` explicitamente quando desejado.

- Pontos observados para evolução futura
  - Cabeçalho User-Agent/Timeouts no WinHTTP (se houver bloqueios de rede específicos).
  - Fallback opcional para página “Downloads” apenas para obter “latest”, se o FTP mudar o HTML.

