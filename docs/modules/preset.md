### Module: preset

- Purpose: register and load presets from `$SZCDF_G__ROOT_DIR/presets`

- Load:
```bash
szcdf_module_manager load preset
```

- Public commands:
  - `szcdf_preset register <preset_name>`: queues a preset; name maps to `presets/<name>` dir or `presets/<name>.sh`
  - `szcdf_preset load_all_registered`: runs staged scripts or single script for each registered preset
  - `szcdf_preset is_loaded <preset_name>`: prints `1` if loaded

- Stages for directory presets:
  - `1*` before-any-load
  - `2*` on-load
  - `3*` after-all-load

- Example:
```bash
szcdf_module_manager load preset
szcdf_preset register add-bash-recommended
szcdf_preset load_all_registered
```