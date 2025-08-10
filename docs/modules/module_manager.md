### Module: module_manager

- Purpose: load/unload modules and track lifecycle

- Load: preloaded by bootstrap; can be loaded manually via bootstrap

- Public commands:
  - `szcdf_module_manager load <module> [path]`: source and initialize a module
  - `szcdf_module_manager is_loaded <module>`: prints `1` and returns 0 if loaded
  - `szcdf_module_manager unload_all_loaded`: unload in reverse order, running `__cleanup` if present

- Example:
```bash
# Load colors and powerline
szcdf_module_manager load colors
szcdf_module_manager load powerline

# Check
if szcdf_module_manager is_loaded colors; then echo ok; fi

# Cleanup at the end
szcdf_module_manager unload_all_loaded
```