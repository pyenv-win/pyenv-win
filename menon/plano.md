# Plano de trabalho — Atualização de versões do Python no pyenv-win

- Objetivo
  - Atualizar a base de versões para refletir os instaladores oficiais “Windows installer (64-bit)” (amd64) e, quando disponível, “Windows installer (ARM64)”. Garantir `pyenv install` para 3.8+ até 3.12/3.13.

- Escopo técnico
  - Fonte primária: `https://www.python.org/ftp/python` (mais completa e estável).
  - Arquiteturas: foco em amd64; incluir arm64 sem confusão. x86 permanece, mas fora de escopo.

- Etapas
  1) Auditoria expressa de coleta/regex
     - Confirmar regex para `-amd64`, `-arm64`, `.exe` e `.msi` (OK).
  2) Ajustes mínimos (se necessários)
     - Sem mudanças obrigatórias. Deixar nota sobre UA/Timeout futuro.
  3) ARM64 sem confusão
     - Manter `-arm64` no XML; usuário escolhe explicitamente ao instalar.
  4) Regenerar a base
     - Executar `pyenv update` para varrer mirrors e salvar `.versions_cache.xml`.
  5) Smoke tests
     - `pyenv install --list` deve conter 3.12.x/3.13.x (amd64) e arm64 quando existir.
     - Instalar `pyenv install 3.12.x` em host x64.
  6) Documentação
     - Orientar a rodar `pyenv update` e escolher arquitetura por sufixo.
  7) Automação rápida
     - Rodar `pyenv update --ignore` automaticamente no fim de `install-pyenv-win.ps1`.

- Critérios de aceite
  - Lista inclui versões atuais (3.12/3.13) com `-amd64` e, quando houver, `-arm64`.
  - Instalação 3.12.x em x64 funciona (shims criados).
  - Preferência por offline quando coexistir com web.

- Riscos e mitigação
  - Mudança de HTML do FTP: manter como primária; considerar fallback futuro.
  - Rede/TLS/Proxy: `--ignore` já ajuda; documentar `http_proxy/https_proxy`.

- Execução (esta PR)
  - [x] Documentação de achados.
  - [x] Plano de trabalho.
  - [x] Hook de `pyenv update` pós-instalação no `install-pyenv-win.ps1`.
  - [ ] Validação local: rodar `pyenv update` e checar `--list`.
  - [ ] Teste instalação 3.12.x.

