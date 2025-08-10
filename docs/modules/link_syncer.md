### Module: link_syncer

- Purpose: ensure a symlink exists from a source path to a destination path, moving conflicts aside

- Load:
```bash
szcdf_module_manager load link_syncer
```

- Public commands:
  - `szcdf_link_syncer ensure_link <src_path> <dest_path>`

- Example:
```bash
szcdf_module_manager load link_syncer
szcdf_link_syncer ensure_link "$SZCDF_G__ROOT_DIR/data/mail_zhaostephen_com.gitconfig" "$HOME/.gitconfig"
```