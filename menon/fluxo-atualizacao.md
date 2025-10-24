# Diagrama — Fluxo de atualização (flowchart LR)

```mermaid
flowchart LR
    A[install-pyenv-win.ps1] --> B{Instala/Atualiza pyenv-win}
    B --> C[Atualiza PATH e variáveis]
    C --> D[Rodar pyenv update --ignore]
    D --> E[Baixar páginas dos mirrors]
    E --> F{python.org/ftp/python}
    F --> G[Descobrir versões (regex)]
    G --> H[Priorizar offline vs web]
    H --> I[Salvar .versions_cache.xml]
    I --> J[pyenv install --list]
    J --> K{Usuário escolhe versão}
    K --> L[pyenv install <versão>]
    L --> M{.msi?}
    M -- sim --> N[msiexec /a]
    M -- não (.exe) --> O[extrair MSIs c/ WiX dark.exe]
    N --> P[ensurepip se existir]
    O --> P
    P --> Q[criar shims + links]
```

