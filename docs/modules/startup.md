### Module: startup

- Purpose: main entry for SZCDF; orchestrates module loading and cleanup

- Public function:
  - `szcdf_startup`: loads `shinter`, `profile`, `preset`; detects and loads profile; loads all registered presets; unloads modules

- Typical usage:
  - Sourced by `_bootstrap.sh`, which is sourced by shell entry scripts appended during install.