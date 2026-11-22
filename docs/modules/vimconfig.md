### Module: vimconfig

- Purpose: manage vim setup, link profile-specific vimrc, and install plugins (Vundle)

- Load:
```bash
szcdf_module_manager load vimconfig
```

- Public commands:
  - `szcdf_vimconfig install-configs`: ensure `~/.vim`, install Vundle if missing, link `~/.vim/vimrc` to profile or default, run `PluginInstall` on change

- Environment:
  - Uses `SZCDF_PROFILE_NAME` if set to link profile-specific `vimrc`

- Example:
```bash
szcdf_module_manager load vimconfig
szcdf_vimconfig install-configs
```