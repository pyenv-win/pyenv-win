# Release Notes — Atualização do index de versões (Windows)

- Objetivo
  - Atualizar e modernizar o índice de versões do pyenv-win para Windows, cobrindo CPython estável atual (amd64/arm64/win32), removendo distribuições não-CPython e pré-releases, e garantindo descoberta via FTP moderno.

- Principais mudanças
  - Coleta robusta (sem DOM): `pyenv-win/libexec/pyenv-update.vbs`
    - Parser por regex do HTML/JSON; suporte a subpastas `amd64/`, `arm64/`, `win32/` no FTP.
    - Remoções: pypy, graalpy e releases `rc`; também filtra `alpha (a)` e `beta (b)`.
    - Síntese de instaladores diretos (fallback): gera entradas para CPython 3.x.y (x ≥ 9) nos formatos `python-<ver>-amd64.exe`, `python-<ver>-arm64.exe`, `python-<ver>.exe` quando o índice não lista links.
    - Otimização de varredura: tenta versões por série e interrompe após 5 falhas consecutivas por série (reduz carga de rede). Intervalo de séries: 3.9 até 3.30; patches tentados 0..30.
  - Padronização ARM
    - Códigos de versão ARM padronizados como `-arm64` (antes havia `-arm` em alguns históricos): `pyenv-win/libexec/libs/pyenv-install-lib.vbs`.
  - Pós-instalação
    - O instalador agora executa `pyenv update --ignore` ao final para pré-popular `.versions_cache.xml`: `pyenv-win/install-pyenv-win.ps1`.

- Itens explicitamente removidos
  - Distribuições: PyPy, GraalPy
  - Releases: rc (release candidate), alpha (aN), beta (bN)

- Cobertura de versões (CPython)
  - Séries alvo: 3.9 até 3.30 (ajustável em `AugmentCPythonSpan`).
  - Patches por série: 0..30, com early-stop após 5 misses consecutivas.
  - Arquiteturas: amd64 (padrão), arm64, win32.

- Comandos (automáticos e manuais)
  - Após instalar via script, o cache de versões é atualizado automaticamente.
  - Manuais:
    - Atualizar base: `cscript //nologo pyenv-win/libexec/pyenv-update.vbs --ignore`
    - Listar: `cscript //nologo pyenv-win/libexec/pyenv-install.vbs --list`
    - Instalar (amd64): `cscript //nologo pyenv-win/libexec/pyenv-install.vbs 3.13.9`
    - Instalar (ARM64): `cscript //nologo pyenv-win/libexec/pyenv-install.vbs 3.13.9-arm64`

- Observações técnicas
  - A síntese direta usa requisições HTTP pequenas (GET Range) para validar a existência de URLs antes de adicioná-las.
  - O índice permanece ordenado semanticamente e prioriza instaladores offline quando coexistem com webinstall.
  - O `pyenv latest` continua escolhendo estáveis (ignora suivos a/b/rc pela lógica de comparação).

- Testes de fumaça executados
  - `3.12.10` (amd64) instalado com sucesso.
  - `3.13.9` (amd64) instalado com sucesso.
  - `--list` exibe o conjunto estável, sem pypy/graalpy/rc.

- Riscos e mitigação
  - Carga de rede: varredura direta é limitada por early-stop; ainda assim mantém o caminho principal via mirrors/índices.
  - Mudanças no FTP: abordagem regex e fallback direto reduzem acoplamento com HTML.

- Próximos ajustes possíveis
  - Tornar `startMinor/endMinor/maxPatch` configuráveis por variável de ambiente.
  - Acrescentar cache incremental (evitar revalidar versões já confirmadas).

