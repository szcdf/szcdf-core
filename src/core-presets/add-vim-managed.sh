#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: add-vim-managed
# Purpose: Add managed settings for vim via the vim module.

szcdf_logging__begin_context 'core-presets/add-vim-managed'

szcdf_logging__debug "Running add-vim-managed..."

szcdf_module_manager load vimconfig

szcdf_vimconfig install-configs

if [[ -n "$SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR" ]]; then
  szcdf_logging__warning "Error installing vim configs. Skipping."
  return 0
fi

szcdf_logging__debug "Finished running add-vim-managed."

szcdf_logging__end_context