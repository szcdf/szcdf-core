#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: use-nord-theme
# Purpose: Use the Nord theme.

szcdf_logging__debug "Using the Nord theme..."

# Set directory colors for ls listings
if [ -x /usr/bin/dircolors ]; then
  test -r $SZCDF_G__ROOT_DIR/data/.dircolors-nord && eval "$(dircolors -b $SZCDF_G__ROOT_DIR/data/.dircolors-nord)" || eval "$(dircolors -b)"
fi

szcdf_logging__debug "Finished using the Nord theme."
