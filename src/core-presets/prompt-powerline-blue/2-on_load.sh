#!/bin/bash
###############################################################################
#
# szcdf_preset
# prompt-powerline-blue/2-on_load.sh
# Stephen Zhao

# The core script to run when the preset is run

szcdf_logging__begin_context 'preset-powerline-prompt-blue/on_load'

szcdf_logging__debug "Setting up PS1..."

if ! szcdf_shinter get_is_interactive; then

  szcdf_logging__info "Shell is not interactive. The on_load of preset-prompt-powerline-blue only applies when the shell is interative. Skipping..."

  szcdf_logging__end_context

  return 0

fi

szcdf_powerline set_ps1_by_color_scheme BLUE

szcdf_logging__debug "Finished setting up PS1."

szcdf_logging__end_context
