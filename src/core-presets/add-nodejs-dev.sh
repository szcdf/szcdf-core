#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-nodejs-dev
# Purpose: Recommended settings for nodejs development.

szcdf_logging__begin_context 'core-presets/add-nodejs-dev'

szcdf_logging__debug "Running add-nodejs-dev..."

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NODE_ENV=development

szcdf_logging__debug "Finished running add-nodejs-dev."

szcdf_logging__end_context
