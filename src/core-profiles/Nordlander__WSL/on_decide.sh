#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: Nordlander__WSL
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Profile
# Purpose: Decides if the Nordlander__WSL profile should be used.

if [[ "$(hostname)" == "Nordlander" && -n $(uname -a | grep -i "Microsoft") ]]; then
  echo 'Nordlander__WSL'
fi
