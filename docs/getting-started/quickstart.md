### Quickstart

- After install, a bootstrap entry is prepended to `~/.profile`, `~/.bash_profile`, and `~/.bashrc`. On new shells, SZCDF loads:
  - `startup` module, which loads `shinter`, `profile`, and `preset`
  - It detects a profile and runs its `on_load.sh`
  - It loads all registered presets

- Verify installation:
  - Open a new bash shell; you should see logs when `DEBUG_MODE` is enabled (touch `/tmp/SZCDF_G__DEBUG_MODE` before launching shell to enable)

- Try a profile and presets:
  - Default profile registers `add-bash-recommended` and `set-shell-prompt-standard`
  - WSL profile `Nordlander__WSL` registers WSL helpers, vim setup, Nord theme, powerline prompt, etc.