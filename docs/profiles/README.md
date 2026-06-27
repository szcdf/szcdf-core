### Profiles

- What is a profile?
  - A set of machine/user-specific presets and environment settings

- Directory structure:
  - `$SZCDF_G__ROOT_DIR/profiles/<name>/on_decide.sh`: prints `<name>` to select this profile, or prints nothing to skip
  - `$SZCDF_G__ROOT_DIR/profiles/<name>/on_load.sh`: registers presets and sets env for the profile

- How selection works:
  - `szcdf_profile detect` iterates `profiles/*`, runs `on_decide.sh` until one prints a name
  - Falls back to `default` if none chosen

- Core profiles:
  - `default`: registers `add-bash-recommended`, `set-shell-prompt-standard`
  - `Nordlander__WSL`: WSL-focused helpers, Nord theme, powerline prompt, vim, conda, node, SSH
  - `szcdf_tester`: for docker test env; imports sample bins

- Create a new profile:
```bash
mkdir -p "$SZCDF_G__ROOT_DIR/profiles/my_profile"
cat > "$SZCDF_G__ROOT_DIR/profiles/my_profile/on_decide.sh" <<'SH'
#!/usr/bin/env bash
if [[ "$(hostname)" == "my-host" ]]; then echo 'my_profile'; fi
SH
chmod +x "$SZCDF_G__ROOT_DIR/profiles/my_profile/on_decide.sh"

cat > "$SZCDF_G__ROOT_DIR/profiles/my_profile/on_load.sh" <<'SH'
#!/usr/bin/env bash
szcdf_preset register add-bash-recommended
szcdf_preset register set-shell-prompt-powerline-blue
SH
chmod +x "$SZCDF_G__ROOT_DIR/profiles/my_profile/on_load.sh"
```