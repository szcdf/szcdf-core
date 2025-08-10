### Installation

- Clone and run the installer:

```bash
git clone git@github.com:szcdf/szcdf-core.git && cd szcdf-core && make install
```

- Installer flags (via `bin/szcdfi.sh`):
  - `-p, --package-dir <dir>`: package directory (defaults to current dir)
  - `-s, --spec <file>`: install spec file (defaults to `.szcdfis` in package dir)
  - `-I, --non-interactive` / `-i, --interactive`: run mode
  - `-m, --mode <1|quick|2|custom>`: installation mode
  - `-h, --help`: usage