#!/bin/bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: set-shell-prompt-powerline-blue
# Purpose: Sets up the powerline prompt in blue.

szcdf_logging__begin_context 'core-presets/set-shell-prompt-powerline-blue'

szcdf_logging__debug "Setting up PS1..."

if ! szcdf_shinter get_is_interactive; then

  szcdf_logging__info "Shell is not interactive. The set-shell-prompt-powerline-blue only applies when the shell is interative. Skipping..."

  szcdf_logging__end_context

  return 0

fi

szcdf_powerline set_ps1_by_color_scheme BLUE

szcdf_logging__debug "Finished setting up PS1."

szcdf_logging__end_context
