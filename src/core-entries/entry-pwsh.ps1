###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Entry Script
# Entry Target: pwsh (Windows PowerShell 5.1 and PowerShell 7+)
# Purpose: The entry point for the SZCDF system when PowerShell is the shell.
#
# This is a THIN, near-fixed per-shell loader. It does NOT reimplement the
# Bash module runtime. It only:
#   1. locates the SZCDF root directory, and
#   2. dot-sources any generated session snippets under `<root>/env.d/*.ps1`.
#
# Session-shaping logic is expected to be GENERATED into env.d/*.ps1 by the
# neutral core (see ADR 0001). Keeping this file thin is deliberate: the
# per-shell surface must stay small.

# Only run this if we have not hit an entry point yet (mirrors entry-bash.sh).
if (-not $env:SZCDF_G__IS_RUNNING_ENTRY_POINT) {
    $env:SZCDF_G__IS_RUNNING_ENTRY_POINT = '1'

    try {
        $szcdfConfigRoot = Join-Path $HOME '.config/szcdf'
        $szcdfDotRoot = Join-Path $HOME '.szcdf'
        if (Test-Path -LiteralPath $szcdfConfigRoot) {
            $env:SZCDF_G__ROOT_DIR = $szcdfConfigRoot
        } elseif (Test-Path -LiteralPath $szcdfDotRoot) {
            $env:SZCDF_G__ROOT_DIR = $szcdfDotRoot
        }

        if ($env:SZCDF_G__ROOT_DIR) {
            $szcdfEnvDir = Join-Path $env:SZCDF_G__ROOT_DIR 'env.d'
            if (Test-Path -LiteralPath $szcdfEnvDir) {
                Get-ChildItem -LiteralPath $szcdfEnvDir -Filter '*.ps1' -File |
                    Sort-Object -Property Name |
                    ForEach-Object { . $_.FullName }
            }
        }
    } finally {
        Remove-Item -LiteralPath Env:\SZCDF_G__IS_RUNNING_ENTRY_POINT -ErrorAction SilentlyContinue
    }
}
