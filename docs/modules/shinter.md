### Module: shinter

- Purpose: detect shell interactivity

- Load:
```bash
szcdf_module_manager load shinter
```

- Public commands:
  - `szcdf_shinter detect_is_interactive`: prints `Y` and returns 0 if interactive
  - `szcdf_shinter detect_and_set_is_interactive`: sets `szcdf_shinter__IS_INTERACTIVE`
  - `szcdf_shinter return_is_interactive`: exit code 0 if interactive, 1 otherwise

- Example:
```bash
if szcdf_shinter return_is_interactive; then
  echo interactive
fi
```