#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-pyenv
# Purpose: pyenv configuration.

szcdf_logging__begin_context 'core-presets/add-pyenv'

szcdf_logging__debug "Running add-pyenv..."

export PYENV_ROOT="$HOME/.pyenv"

if [[ ! -e "$PYENV_ROOT" ]]; then
  szcdf_logging__warning "pyenv requested, but pyenv is not installed. Skipping."
  return 0
fi

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"

szcdf_logging__debug "Finished running add-pyenv."

szcdf_logging__end_context
