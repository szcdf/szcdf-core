### SZCDF Installer (`szcdfi.sh`)

- Purpose: Install/activate the SZCDF package into a user's home/config via a spec file.
- Usage:

```bash
bin/szcdfi.sh [-p <dir>] [-s <file>] [-I| -i] [-m <mode>] [-h]
```

- Modes:
  - `1` or `quick`: preview entire plan then execute
  - `2` or `custom`: step through each directive with prompts

- Spec resolution:
  - Default spec: `<pkg_dir>/.szcdfis`
  - Default pkg_dir: parent of `bin/`

- Directives:
  - `COPY <source> <dest>`: create a symlink at `<dest>` pointing to `<pkg_dir>/<source>`; prompts on conflict
  - `COPYALL <source_dir> <dest_dir>`: non-recursively apply COPY to each file inside `<source_dir>` into `<dest_dir>`
  - `PREPENDTEXT <source> <dest> <section_id> [comment_indicator]`: ensure a managed section at top of `<dest>`; if present, replace contents; default comment indicator `#`
  - `APPENDTEXT <source> <dest> <section_id> [comment_indicator]`: ensure a managed section at end of `<dest>`; if present, replace contents; default `#`

- Markers used by text directives:
  - Begin: `<comment> >>>>>>> SZCDF_GENERATED_TEXT // BEGIN SECTION_ID=<id> // DO NOT EDIT MANUALLY`
  - End: `<comment> <<<<<<< SZCDF_GENERATED_TEXT // END SECTION_ID=<id> // DO NOT EDIT MANUALLY`

- Examples:
```bash
# Quick install using repo defaults
make install

# Non-interactive quick run against a custom spec
bin/szcdfi.sh -I -s /path/to/.szcdfis -m quick

# Custom mode from a specific package directory
bin/szcdfi.sh -p ~/dotfiles/szcdf-core -m custom
```