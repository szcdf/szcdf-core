#!/bin/bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: add-conda-recommended
# Purpose: Recommended settings for conda.

szcdf_logging__begin_context 'core-presets/add-conda-recommended'

szcdf_logging__debug "Running add-conda-recommended..."

if [[ ! -e "$HOME/miniconda3/bin/conda" ]]; then
  szcdf_logging__warning "conda environment requested, but conda is not installed. Skipping."
  return 0
fi

__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup

szcdf_logging__debug "Finished running add-conda-recommended."

szcdf_logging__end_context
