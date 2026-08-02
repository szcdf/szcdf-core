# ADR 0001: Multi-shell support for SZCDF

- Status: Proposed
- Date: 2026-08-02
- Deciders: Stephen Zhao
- Supersedes: none

## Context

SZCDF is a dotfiles framework built entirely in Bash.

- The framework runs in two phases:
  - Install phase.
    - `bin/szcdfi.sh` reads the `.szcdfis` manifest.
    - It applies directives (`COPY`, `COPYALL`, `PREPENDTEXT`, `APPENDTEXT`).
    - It copies or links the package into `$CONFIG_ROOT` (`~/.config/szcdf` or `~/.szcdf`).
    - It prepends entry hooks into `~/.bashrc`, `~/.profile`, and `~/.bash_profile`.
  - Runtime phase.
    - An entry script (`src/core-entries/entry-bash.sh`) is sourced from the shell run-command files.
    - The entry sources `_bootstrap.sh`, which loads `logging` and `module_manager`, then `startup`.
    - Modules and presets are `source`d Bash functions with an `__init` / `__cleanup` lifecycle.
- Both phases depend on Bash-only features.
  - `declare -gA` associative arrays.
  - `${var+_}` parameter expansion.
  - `local -n` namerefs.
  - `BASH_SOURCE` and `source`.

The framework must also work on Windows-native shells (PowerShell), where Bash is not present.

- A WSL or Git Bash install is not an acceptable dependency for the Windows-native path.
- A child Bash process cannot shape a parent PowerShell session (environment, prompt, aliases).

## Decision

Adopt a **split-by-effect-type** architecture, not a per-shell rewrite of the whole framework.

### Principle: two kinds of work with different portability limits

- Provisioning (out-of-process effects).
  - Copies files, creates links, writes managed files (for example the managed `CLAUDE.md`).
  - Touches the filesystem, not the live shell.
  - A child process in any language can do this.
  - Result: centralize into ONE engine.
- Session shaping (in-process effects).
  - Sets environment variables, `PATH`, aliases, functions, the prompt, and shell options.
  - Must run inside the live shell's own process and language.
  - A child process cannot inject these into its parent.
  - Result: inherently per-shell; cannot be centralized.

### Target architecture: "neutral core computes, native adapters apply"

- Layer 0 — Manifest (`.szcdfis`).
  - Stays declarative and shell-neutral.
  - Gains shell guards so one manifest can drive every installer (see "Guard model").
- Layer 1 — Installer.
  - The directive surface is small (four directives).
  - Provide one installer per bootstrap environment that reads the same manifest.
  - `bin/szcdfi.sh` for Bash. `bin/szcdfi.ps1` for PowerShell.
- Layer 2 — Entry scripts (`src/core-entries/entry-<shell>`).
  - Already per-shell by design.
  - Each is a thin, near-fixed loader for its shell.
- Layer 3 — Engine, split in two.
  - Provisioner (out-of-process): implemented once; avoids the N-times rewrite.
  - Session shaper (in-process): compiled, not interpreted.
    - The neutral core generates static native snippets at install time (`env.d/*.ps1`, `env.d/*.sh`).
    - The per-shell entry only sources those snippets.
- Layer 4 — Modules and presets.
  - Each declares `kind = provisioning | session` and `supports = [bash, pwsh, ...]`.
  - Provisioning presets: authored once, run by the provisioner.
  - Session presets: authored as generators that emit per-shell snippets; kept deliberately small.

### Guard model

- A guarded directive uses a leading comment token: `#@<shell> <DIRECTIVE> <args...>`.
- Property: a guarded line is a comment to every OTHER installer, and an active directive to the matching one.
  - The existing Bash installer already treats `#`-prefixed lines as comments and skips them silently.
  - So `#@pwsh ...` lines are invisible to Bash with NO change to `bin/szcdfi.sh`.
- Important limit discovered during design:
  - Guards can only ADD per-shell lines. They cannot retroactively make an existing SHARED line bash-only.
  - Tagging an existing shared line `#@bash` would make Bash skip it too (Bash sees a comment).
  - To make shared lines bash-only, the Bash installer must be upgraded to treat `#@bash` as ACTIVE.
  - That upgrade is deferred to Phase 2 (see "Consequences").

## Consequences

- Positive.
  - The irreducible per-shell surface is small: one installer per bootstrap environment, one thin entry per shell.
  - Provisioning logic, the manifest, and managed content stay written once.
  - The managed `CLAUDE.md` reaches Windows through provisioning only; it needs no ported runtime.
- Negative / cost.
  - At least two installers now exist, so they can drift.
    - Mitigation: a conformance test that runs both installers against the same manifest and asserts the same result tree.
  - Session shaping still needs per-shell snippets; only their GENERATION is shared.
- Migration in phases.
  - Phase 1 (this change): unblock Windows provisioning.
    - Add `bin/szcdfi.ps1` (reads `.szcdfis`, honors guards, resolves `$PROFILE`).
    - Add `src/core-entries/entry-pwsh.ps1` (thin loader for `env.d/*.ps1`).
    - Add `src/core-data/CLAUDE.user.md` (the managed content).
    - Add `src/core-presets/add-claude-md-managed.ps1` (`kind = provisioning`; writes an `@import` stub).
    - Add `windows.szcdfis` (a curated Windows spec, so the proven Bash flow is not touched yet).
  - Phase 2: converge to a single manifest.
    - Upgrade `bin/szcdfi.sh` to treat `#@bash` as active.
    - Retire `windows.szcdfis` in favor of guarded lines in `.szcdfis`.
    - Formalize `kind` / `supports` metadata on presets.
    - Move session presets to the generator model that emits `env.d/*`.
  - Phase 3: conformance harness.
    - Add a Windows CI runner that runs `bin/szcdfi.ps1` against the manifest.
    - Assert the same result tree that `test/installer` asserts on Linux.

## Text encoding and line endings (installer parity)

- All PowerShell text writers emit UTF-8 WITHOUT a BOM.
  - A BOM before the first line breaks Claude Code's `@import` parsing.
  - No-BOM also matches the byte output of `szcdfi.sh`.
- All content reads pass `-Encoding UTF8`.
  - Windows PowerShell 5.1 otherwise decodes with the system ANSI code page.
  - That would mojibake-corrupt any non-ASCII content in a file it edits (for example a user's `$PROFILE`).
- `PREPENDTEXT` / `APPENDTEXT` preserve the destination file's dominant EOL.
  - A pre-existing CRLF file stays CRLF; a new file defaults to LF.
  - This avoids silently normalizing untouched user lines, and matches the Bash `awk`-replace path, which also keeps the destination EOL.

## Known parity limitations (Phase 2 backlog)

- New-section insert vs a source file with no trailing newline.
  - `szcdfi.sh` `cat`s the source, so a source without a final newline glues the END marker onto the source's last line.
  - `szcdfi.ps1` always places the END marker on its own line (the correct behavior).
  - The Bash new-section path is internally inconsistent (its `awk`-replace path adds a newline).
  - Resolution: fix `szcdfi.sh` to add the newline; do NOT replicate the Bash gluing bug.
  - Not reachable today: every referenced source file ends in LF.
- Copy over an existing symlink destination (editable/dev flows).
  - `szcdfi.sh` replaces a symlink destination with a regular file even when contents match.
  - `szcdfi.ps1` currently keeps the symlink when the linked content hashes equal.
  - Low impact: Windows symlinks need Developer Mode or admin, so this is a dev-only path.
  - Resolution: add explicit symlink-type detection to `Copy-One` in Phase 2.

## The Windows managed `CLAUDE.md`: why an import stub, not a symlink

- The Bash path provisions `~/.claude/CLAUDE.md` with a symlink via `link_syncer`.
- On Windows-native, a symlink needs Developer Mode or administrator rights.
- An `@import` stub avoids that.
  - Claude Code supports `@path` imports inside `CLAUDE.md`.
  - The stub is one line: `@<forward-slash path to the installed CLAUDE.user.md>`.
  - It needs no elevated rights.
  - It is composable: a machine can keep local lines above the import.

## Alternatives considered

- Full polyglot port.
  - Reimplement the bootstrap and every module in each shell.
  - Rejected: N-times maintenance and constant divergence.
- Bash engine everywhere (ship Git Bash or WSL on Windows).
  - Rejected: works for provisioning only.
  - A child Bash cannot shape the parent PowerShell session.

## How to try Phase 1

- Install (PowerShell), against an isolated home for safety:
  - `pwsh -File bin/szcdfi.ps1 -Spec windows.szcdfis -NonInteractive`
- Provision the managed `CLAUDE.md`:
  - `pwsh -File "$env:USERPROFILE/.config/szcdf/presets/add-claude-md-managed.ps1"`
- Verify:
  - `Get-Content "$env:USERPROFILE/.claude/CLAUDE.md"` shows a single `@...CLAUDE.user.md` line.
