###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Installer
# Target: pwsh (Windows PowerShell 5.1 and PowerShell 7+)
# Purpose: PowerShell installer for the SZCDF package system.
#
# This is the PowerShell sibling of bin/szcdfi.sh. It reads the SAME declarative
# install-spec format (.szcdfis) and applies the SAME directives:
#   COPY, COPYALL, PREPENDTEXT, APPENDTEXT
#
# It additionally understands shell GUARDS so one manifest can serve every
# installer (see ADR 0001):
#   `#@pwsh <DIRECTIVE> ...`  -> active for THIS installer only.
#   `#@<other> <DIRECTIVE>`   -> ignored by THIS installer.
#   `<DIRECTIVE> ...`         -> shared; processed by every installer.
#   `# ...`                   -> ordinary comment.
#
# The section-marker format used by PREPENDTEXT / APPENDTEXT is byte-identical
# to bin/szcdfi.sh, so the two installers are interoperable on the same files.

[CmdletBinding()]
param(
    [Alias('p')][string] $PackageDir,
    [Alias('s')][string] $Spec,
    [Alias('m')][ValidateSet('quick', 'custom')][string] $Mode = 'quick',
    [Alias('I')][switch] $NonInteractive,
    [Alias('e')][switch] $Editable
)

$ErrorActionPreference = 'Stop'

# Write text as UTF-8 WITHOUT a BOM and with LF line endings, to match the
# byte output of bin/szcdfi.sh (awk/printf/cat). A BOM would, for example,
# break Claude Code's `@import` parsing when it precedes the first line.
function Write-TextFileLf {
    param([string] $Path, [string[]] $Lines)
    $content = ($Lines -join "`n")
    if ($content.Length -gt 0) { $content += "`n" }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $content, $utf8NoBom)
}

# The shell identity this installer answers to, for guard matching.
# (Named SzcdfShellId to avoid the built-in read-only $ShellId automatic variable.)
$script:SzcdfShellId = 'pwsh'


######### PATH / ROOT RESOLUTION #############################################

function Get-SzcdfConfigRoot {
    $dotConfig = Join-Path $HOME '.config/szcdf'
    $dotSzcdf = Join-Path $HOME '.szcdf'
    if (Test-Path -LiteralPath $dotConfig -PathType Container) { return $dotConfig }
    if (Test-Path -LiteralPath $dotSzcdf -PathType Container) { return $dotSzcdf }
    # Neither exists yet: default to ~/.config/szcdf and create it.
    New-Item -ItemType Directory -Force -Path $dotConfig | Out-Null
    return $dotConfig
}

function Resolve-SpecPath {
    param([string] $Raw, [string] $ConfigRoot)
    # Substitute the same tokens the Bash installer supports, plus $PROFILE.
    $out = $Raw
    $out = $out.Replace('$CONFIG_ROOT', $ConfigRoot)
    $out = $out.Replace('$HOME', $HOME)
    $out = $out.Replace('$PROFILE', $PROFILE.CurrentUserAllHosts)
    return $out
}


######### DIRECTIVE EXECUTORS ################################################

function Copy-One {
    param([string] $SourceAbs, [string] $DestAbs)

    $destParent = Split-Path -Parent $DestAbs
    if ($destParent -and -not (Test-Path -LiteralPath $destParent)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }

    if ($Editable) {
        # Editable mode: symbolic link (needs Developer Mode or admin on Windows).
        if (Test-Path -LiteralPath $DestAbs) { Remove-Item -LiteralPath $DestAbs -Recurse -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $DestAbs -Target $SourceAbs | Out-Null
            Write-Output "  linked  $DestAbs -> $SourceAbs"
        } catch {
            Write-Warning "  symlink failed ($($_.Exception.Message)); falling back to copy."
            Copy-Item -LiteralPath $SourceAbs -Destination $DestAbs -Recurse -Force
            Write-Output "  copied  $SourceAbs -> $DestAbs"
        }
        return
    }

    if (Test-Path -LiteralPath $SourceAbs -PathType Container) {
        # Directory copy with replace semantics (mirror cp -rfT: dest becomes src).
        if (Test-Path -LiteralPath $DestAbs) { Remove-Item -LiteralPath $DestAbs -Recurse -Force }
        Copy-Item -LiteralPath $SourceAbs -Destination $DestAbs -Recurse -Force
    } else {
        # File copy. Skip if identical (idempotency).
        if (Test-Path -LiteralPath $DestAbs -PathType Leaf) {
            $a = (Get-FileHash -LiteralPath $SourceAbs -Algorithm SHA256).Hash
            $b = (Get-FileHash -LiteralPath $DestAbs -Algorithm SHA256).Hash
            if ($a -eq $b) {
                Write-Output "  skip    $DestAbs (identical)"
                return
            }
        }
        Copy-Item -LiteralPath $SourceAbs -Destination $DestAbs -Force
    }
    Write-Output "  copied  $SourceAbs -> $DestAbs"
}

function Invoke-Copy {
    param([string[]] $Tokens, [string] $PkgDir, [string] $ConfigRoot)
    if ($Tokens.Count -lt 2) { Write-Warning 'COPY needs <source> <dest>. Skipping.'; return }
    $srcAbs = Join-Path $PkgDir $Tokens[0]
    $destAbs = Resolve-SpecPath -Raw $Tokens[1] -ConfigRoot $ConfigRoot
    if (-not (Test-Path -LiteralPath $srcAbs)) {
        Write-Warning "COPY source not found: $srcAbs. Skipping."
        return
    }
    Copy-One -SourceAbs $srcAbs -DestAbs $destAbs
}

function Invoke-CopyAll {
    param([string[]] $Tokens, [string] $PkgDir, [string] $ConfigRoot)
    if ($Tokens.Count -lt 2) { Write-Warning 'COPYALL needs <source_dir> <dest_dir>. Skipping.'; return }
    $srcDirAbs = Join-Path $PkgDir $Tokens[0]
    $destDirRaw = $Tokens[1]
    if (-not (Test-Path -LiteralPath $srcDirAbs -PathType Container)) {
        Write-Warning "COPYALL source dir not found: $srcDirAbs. Skipping."
        return
    }
    # Non-recursive: iterate direct children (files and dirs), COPY each.
    Get-ChildItem -LiteralPath $srcDirAbs -Force | ForEach-Object {
        $childSrcAbs = $_.FullName
        $childDestAbs = Resolve-SpecPath -Raw (($destDirRaw.TrimEnd('/')) + '/' + $_.Name) -ConfigRoot $ConfigRoot
        Copy-One -SourceAbs $childSrcAbs -DestAbs $childDestAbs
    }
}

function Get-SectionMarkers {
    param([string] $CommentIndicator, [string] $SectionId)
    return [pscustomobject]@{
        Begin = "$CommentIndicator >>>>>>> SZCDF_GENERATED_TEXT // BEGIN SECTION_ID=$SectionId // DO NOT EDIT MANUALLY"
        End   = "$CommentIndicator <<<<<<< SZCDF_GENERATED_TEXT // END SECTION_ID=$SectionId // DO NOT EDIT MANUALLY"
    }
}

function Read-Lines {
    param([string] $Path)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return @(Get-Content -LiteralPath $Path)
    }
    return @()
}

function Invoke-InsertText {
    param(
        [string[]] $Tokens,
        [string] $PkgDir,
        [string] $ConfigRoot,
        [ValidateSet('prepend', 'append')][string] $Position
    )
    if ($Tokens.Count -lt 3) {
        Write-Warning "$($Position.ToUpper())TEXT needs <source> <dest> <section_id>. Skipping."
        return
    }
    $srcAbs = Join-Path $PkgDir $Tokens[0]
    $destAbs = Resolve-SpecPath -Raw $Tokens[1] -ConfigRoot $ConfigRoot
    $sectionId = $Tokens[2]
    $comment = if ($Tokens.Count -ge 4 -and $Tokens[3]) { $Tokens[3] } else { '#' }

    if (-not (Test-Path -LiteralPath $srcAbs -PathType Leaf)) {
        Write-Warning "Source file not found: $srcAbs. Skipping."
        return
    }
    $destParent = Split-Path -Parent $destAbs
    if ($destParent -and -not (Test-Path -LiteralPath $destParent)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }

    $m = Get-SectionMarkers -CommentIndicator $comment -SectionId $sectionId
    $srcLines = Read-Lines -Path $srcAbs
    $destLines = Read-Lines -Path $destAbs

    $hasBegin = $destLines -contains $m.Begin
    $hasEnd = $destLines -contains $m.End

    if ($hasBegin -and $hasEnd) {
        # Replace the existing section body in place.
        $result = New-Object System.Collections.Generic.List[string]
        $inSection = $false
        foreach ($line in $destLines) {
            if ($line -eq $m.Begin) {
                $result.Add($m.Begin)
                foreach ($s in $srcLines) { $result.Add($s) }
                $inSection = $true
                continue
            }
            if ($inSection) {
                if ($line -eq $m.End) { $result.Add($m.End); $inSection = $false }
                continue
            }
            $result.Add($line)
        }
        Write-TextFileLf -Path $destAbs -Lines $result
    } else {
        $section = New-Object System.Collections.Generic.List[string]
        $section.Add($m.Begin)
        foreach ($s in $srcLines) { $section.Add($s) }
        $section.Add($m.End)

        if ($Position -eq 'prepend') {
            $result = New-Object System.Collections.Generic.List[string]
            foreach ($s in $section) { $result.Add($s) }
            foreach ($line in $destLines) { $result.Add($line) }
        } else {
            $result = New-Object System.Collections.Generic.List[string]
            foreach ($line in $destLines) { $result.Add($line) }
            foreach ($s in $section) { $result.Add($s) }
        }
        Write-TextFileLf -Path $destAbs -Lines $result
    }
    Write-Output "  ${Position}ed section '$sectionId' -> $destAbs"
}


######### SPEC PARSING #######################################################

# Returns $null for lines that are not active for this installer (comments,
# empty lines, or lines guarded for a different shell). Otherwise returns the
# active directive text (with any matching guard prefix stripped).
function Get-ActiveDirective {
    param([string] $Line)
    $t = $Line.Trim()
    if ($t.Length -eq 0) { return $null }
    if ($t.StartsWith('#@')) {
        # Guarded line: `#@<shell> <directive...>`
        $m = [regex]::Match($t, '^#@(\S+)\s+(.*)$')
        if (-not $m.Success) { return $null }
        $guard = $m.Groups[1].Value
        if ($guard -eq $script:SzcdfShellId) { return $m.Groups[2].Value }
        return $null
    }
    if ($t.StartsWith('#')) { return $null }  # ordinary comment
    return $t
}


######### MAIN ###############################################################

function Invoke-SzcdfInstall {
    $scriptDir = Split-Path -Parent $PSCommandPath

    if (-not $PackageDir) { $PackageDir = Split-Path -Parent $scriptDir }  # repo root = bin/..
    if (-not $Spec) {
        $winSpec = Join-Path $PackageDir 'windows.szcdfis'
        $defSpec = Join-Path $PackageDir '.szcdfis'
        if (Test-Path -LiteralPath $winSpec) { $Spec = $winSpec } else { $Spec = $defSpec }
    }
    if (-not (Test-Path -LiteralPath $Spec -PathType Leaf)) {
        throw "Install spec not found: $Spec"
    }

    $configRoot = Get-SzcdfConfigRoot

    Write-Output ''
    Write-Output '=== Stephen''s dotfiles (PowerShell installer) ==='
    Write-Output ''
    Write-Output "Package dir : $PackageDir"
    Write-Output "Spec file   : $Spec"
    Write-Output "Config root : $configRoot"
    Write-Output "Mode        : $Mode$(if ($Editable) { ' (editable/symlink)' } else { '' })"
    Write-Output ''

    $lines = Get-Content -LiteralPath $Spec
    $step = 0
    foreach ($line in $lines) {
        $directive = Get-ActiveDirective -Line $line
        if ($null -eq $directive) { continue }

        $tokens = [regex]::Split($directive.Trim(), '\s+')
        $name = $tokens[0]
        $rest = @()
        if ($tokens.Count -gt 1) { $rest = $tokens[1..($tokens.Count - 1)] }

        $step++

        if ($Mode -eq 'custom' -and -not $NonInteractive) {
            $answer = Read-Host "[Step $step] $directive`nRun? [Y/n]"
            if ($answer -match '^(n|no)$') { Write-Output '  skipped'; continue }
        } else {
            Write-Output "[Step $step] $directive"
        }

        switch ($name) {
            'COPY'        { Invoke-Copy    -Tokens $rest -PkgDir $PackageDir -ConfigRoot $configRoot }
            'COPYALL'     { Invoke-CopyAll -Tokens $rest -PkgDir $PackageDir -ConfigRoot $configRoot }
            'PREPENDTEXT' { Invoke-InsertText -Tokens $rest -PkgDir $PackageDir -ConfigRoot $configRoot -Position 'prepend' }
            'APPENDTEXT'  { Invoke-InsertText -Tokens $rest -PkgDir $PackageDir -ConfigRoot $configRoot -Position 'append' }
            default       { Write-Warning "Unknown directive '$name' will be ignored." }
        }
    }

    Write-Output ''
    Write-Output 'Installation was successful!'
}

Invoke-SzcdfInstall
