# szcdf-core

The core component of the SZCDF (Stephen Zhao Configuration Dot Files) system.

## How to Use

Run the following command:
```sh
git clone git@github.com:szcdf/szcdf-core.git && cd szcdf-core && make install
```
Then follow the instructions in the installer.

## Personal packages

szcdf-core holds only the shared parts: installer, modules, generic presets, the `default` and `szcdf_tester` profiles, and the files they use. Machine-specific profiles, presets and data live in separate personal packages. Each has its own `.szcdfis` and installs into the same config root after szcdf-core (`~/.local/bin/szcdfi.sh -p <package-dir>`). The installer copies entry by entry and never clears a folder, so the packages coexist as long as file names don't collide.

## Planning and tracking

Plans, ADRs and work items for szcdf-core live in [szcdf/szcdf-szsdlc](https://github.com/szcdf/szcdf-szsdlc), not in this repo. `.claude/settings.json` points [szsdlc](https://pypi.org/project/zhaostephen-szsdlc/) there (`SZSDLC_BACKEND=git`), so `szsdlc` commands run from this repo, and Claude Code sessions in it, read and write the tracker through a local clone that syncs automatically. Reference code and PRs to tracker IDs (for example ADR-0001) instead of adding docs here. Override per machine in `.claude/settings.local.json` (git-ignored).

## How to Develop

### How to Test

Prerequisite: docker.

1. Run `make enter-test-env` to build the docker image and start an interactive container.
2. Inside the container, run `./install.sh` to test the installer. This script invokes the installer with the `-e` (editable) flag so files are symlinked for faster iteration during development.
   - Run `./reset.sh` to undo the installation when you need to retest the installer.
   - Optionally install any packages you may need to aid in testing (e.g. `sudo apt install vim` to test the vimconfig module).
3. Run `bash` to start a new bash shell and see the dotfiles come into effect.
4. Test the final environment.