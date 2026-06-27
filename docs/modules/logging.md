### Module: logging

- Load:
```bash
szcdf_module_manager load logging
```

- Public functions:
  - `szcdf_logging__init`: initialize context stack
  - `szcdf_logging__begin_context <name>` / `szcdf_logging__end_context`: push/pop logging context
  - `szcdf_logging__debug <msg...>`: debug to stderr when `SZCDF_G__DEBUG_MODE=1`
  - `szcdf_logging__info <msg...>`: info to stderr
  - `szcdf_logging__warning <msg...>`: warning to stderr in yellow
  - `szcdf_logging__error <msg...>`: error to stderr in red

- Example:
```bash
szcdf_module_manager load logging
szcdf_logging__begin_context mytask
szcdf_logging__info "Starting"
szcdf_logging__debug "Details..."
szcdf_logging__end_context
```