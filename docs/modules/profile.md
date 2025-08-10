### Module: profile

- Purpose: detect profile, expose it, and run per-profile `on_load.sh`

- Load:
```bash
szcdf_module_manager load profile
```

- Public commands:
  - `szcdf_profile detect`: prints a profile name based on `profiles/*/on_decide.sh`
  - `szcdf_profile get`: prints the cached/detected profile name
  - `szcdf_profile load <name>`: sources `profiles/<name>/on_load.sh`
  - `szcdf_profile detect_and_load`: detect, set env, and load

- Environment:
  - `SZCDF_PROFILE_NAME`: set by `__setenv`
  - `SZCDF_PROFILE__IS_LOGIN`: set when entrypoint is a login shell

- Example:
```bash
szcdf_module_manager load profile
name=$(szcdf_profile detect)
export SZCDF_PROFILE_NAME="$name"
szcdf_profile load "$name"
```