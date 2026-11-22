### Presets

- What is a preset?
  - A small shell script or a directory of staged scripts to apply a set of settings

- Where are they loaded from?
  - `$SZCDF_G__ROOT_DIR/presets`

- Types:
  - Single script: `presets/<name>.sh`
  - Directory with stages: `presets/<name>/1*.sh`, `2*.sh`, `3*.sh`

- How to register and load:
```bash
szcdf_module_manager load preset
szcdf_preset register <name>
szcdf_preset load_all_registered
```

- Core presets:
  - `add-bash-recommended`: sensible bash defaults and aliases
  - `add-conda-recommended`: initialize conda if installed
  - `add-nodejs-dev`: load nvm and dev-friendly defaults
  - `add-ssh-ids-to-keychain`: load SSH identities via keychain
  - `add-vim-managed`: install and link vim configs via `vimconfig`
  - `add-wsl-recommended`: helpers for Windows paths and drive letters
  - `add-zhaonetwork1-accessor`: add specific SSH key to keychain
  - `use-nord-theme`: set Nord dircolors
  - `set-shell-prompt-standard`: standard bash PS1
  - `set-shell-prompt-powerline-{blue,gold,purple}`: powerline PS1 with themes