#!/usr/bin/env bash
###############################################################################
#
# szcdf_profile
# Nordlander__WSL/on_decide.sh
# Stephen Zhao

if [[ "$(hostname)" == "Nordlander" && -n $(uname -a | grep -i "Microsoft") ]]; then
  # echo 'Nordlander__WSL'
  return
fi
