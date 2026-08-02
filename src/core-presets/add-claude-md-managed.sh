#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-claude-md-managed
# Purpose: Provision the managed CLAUDE.md into the default user-level location
#          for Claude Code (~/.claude/CLAUDE.md).

szcdf_logging__begin_context 'core-presets/add-claude-md-managed'

szcdf_logging__debug "Running add-claude-md-managed..."

szcdf_module_manager load link_syncer

szcdf_link_syncer ensure_link \
  "$SZCDF_G__ROOT_DIR/data/CLAUDE.user.md" \
  "$HOME/.claude/CLAUDE.md"

szcdf_logging__debug "Finished running add-claude-md-managed."

szcdf_logging__end_context
