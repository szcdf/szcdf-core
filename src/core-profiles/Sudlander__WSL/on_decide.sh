#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: Sudlander__WSL
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Profile Decider
# Purpose: Decides if the Sudlander__WSL profile should be used.

if [[ "$(hostname)" == "Sudlander" && -n $(uname -a | grep -i "Microsoft") ]]; then
  echo 'Sudlander__WSL'
fi
