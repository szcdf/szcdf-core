### Entries

- Bash entry: `entry-bash.sh`
  - Prepended to `~/.profile`, `~/.bash_profile`, and `~/.bashrc`
  - Sets `SZCDF_G__ROOT_DIR` to `~/.config/szcdf` or `~/.szcdf`
  - Sets `SZCDF_G__DEBUG_MODE=1` when `/tmp/SZCDF_G__DEBUG_MODE` exists
  - Sources `$SZCDF_G__ROOT_DIR/_bootstrap.sh`

- To enable debug logs before starting a new shell:
```bash
touch /tmp/SZCDF_G__DEBUG_MODE
```