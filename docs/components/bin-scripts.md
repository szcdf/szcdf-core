### Bin Scripts

- Shipped scripts (installed under `$SZCDF_G__ROOT_DIR/bin`):
  - `hello_world.sh`: prints "Hello, world!"
  - `change_win_drive.sh <letter>`: change directory to `/mnt/<letter>` for WSL drive navigation

- Expose on PATH via `bin_manager`:
```bash
szcdf_module_manager load bin_manager
szcdf_bin_manager import hello_world.sh
hello_world.sh
```