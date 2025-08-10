### Bootstrapper: `_bootstrap.sh`

- Purpose: minimal loader that brings up logging and module_manager, then delegates to `startup`
- Behavior:
  - Defines arrays for tracking module states
  - Manually sources and inits `logging` and `module_manager`
  - Loads `startup` via `szcdf_module_manager load startup` and calls `szcdf_startup`

- Expected environment variables before sourcing:
  - `SZCDF_G__ROOT_DIR`: the config root directory (set by entry script)
  - `SZCDF_G__DEBUG_MODE`: `1` to enable debug logs