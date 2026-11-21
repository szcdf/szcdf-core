###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-claude-md-managed
# Kind: provisioning (out-of-process)
# Supports: pwsh
# Purpose: Provision the managed CLAUDE.md into the default user-level location
#          for Claude Code (~/.claude/CLAUDE.md) on Windows-native PowerShell.
#
# This is a PROVISIONING preset: it only touches the filesystem, so it is safe
# to run standalone and needs no SZCDF runtime. It writes an `@import` stub
# rather than a symlink, so it needs no Developer Mode or administrator rights.
#
# Usage:
#   pwsh -File add-claude-md-managed.ps1
#   (SZCDF_G__ROOT_DIR is used if set; otherwise the config root is discovered.)

[CmdletBinding()]
param(
    # Override the target CLAUDE.md path (defaults to ~/.claude/CLAUDE.md).
    [string] $TargetPath
)

$ErrorActionPreference = 'Stop'

function Resolve-SzcdfRoot {
    if ($env:SZCDF_G__ROOT_DIR) {
        return $env:SZCDF_G__ROOT_DIR
    }
    $candidateConfig = Join-Path $HOME '.config/szcdf'
    $candidateDot = Join-Path $HOME '.szcdf'
    if (Test-Path -LiteralPath $candidateConfig) { return $candidateConfig }
    if (Test-Path -LiteralPath $candidateDot) { return $candidateDot }
    throw "Could not locate the SZCDF config root (looked for SZCDF_G__ROOT_DIR, '$candidateConfig', '$candidateDot')."
}

$root = Resolve-SzcdfRoot
$source = Join-Path $root 'data/CLAUDE.user.md'
if (-not (Test-Path -LiteralPath $source)) {
    throw "Managed CLAUDE.user.md not found at '$source'. Run the installer first."
}

if (-not $TargetPath) {
    $TargetPath = Join-Path $HOME '.claude/CLAUDE.md'
}
$targetDir = Split-Path -Parent $TargetPath
if (-not (Test-Path -LiteralPath $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# Forward slashes: Claude Code resolves the import path with node-style path
# resolution, which accepts forward slashes on Windows and avoids backslash
# escaping ambiguity.
$importPath = ((Resolve-Path -LiteralPath $source).Path) -replace '\\', '/'
$stub = "@$importPath"

# Idempotency: if the target already contains exactly our stub, do nothing.
# Trim tolerates a trailing newline and a possible leading BOM from an older write.
if (Test-Path -LiteralPath $TargetPath) {
    # -Encoding UTF8: Windows PowerShell 5.1 otherwise reads as ANSI and would
    # mis-compare a UTF-8 stub (our writer emits UTF-8 without BOM).
    $existing = (Get-Content -LiteralPath $TargetPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)
    if ($null -ne $existing -and $existing.Trim([char]0xFEFF, "`r", "`n", ' ', "`t") -eq $stub) {
        Write-Output "Managed CLAUDE.md already points to '$importPath'. Skipping."
        return
    }
    # Preserve any pre-existing content, mirroring link_syncer's `.old` backup.
    $backup = "$TargetPath.old"
    Write-Warning "'$TargetPath' already exists. Moving it to '$backup'."
    Move-Item -LiteralPath $TargetPath -Destination $backup -Force
}

# Write UTF-8 WITHOUT a BOM: a BOM before `@` can break Claude Code's import parsing.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($TargetPath, "$stub`n", $utf8NoBom)
Write-Output "Wrote managed CLAUDE.md import stub -> $TargetPath"
Write-Output "  imports: $importPath"
