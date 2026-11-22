### Module: bin_manager

- Purpose: manage `bin/` scripts and expose them on `$PATH` via `~/.local/bin`

- Load:
```bash
szcdf_module_manager load bin_manager
```

- Public commands:
  - `szcdf_bin_manager list`: list available scripts in `$SZCDF_G__ROOT_DIR/bin`
  - `szcdf_bin_manager import <script>`: symlink to `~/.local/bin/<script>`
  - `szcdf_bin_manager import_all`: import all scripts in `bin/`
  - `szcdf_bin_manager remove <script>`: remove managed symlink
  - `szcdf_bin_manager clean`: remove broken managed symlinks

- Example:
```bash
szcdf_module_manager load bin_manager
szcdf_bin_manager import hello_world.sh
hello_world.sh
```