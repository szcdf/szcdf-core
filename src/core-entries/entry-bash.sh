#!/bin/bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Entry
# Entry Target: bash
# Purpose: The entry point for the SZCDF system when bash is the shell.
#
# This script sources the bootstrapper.

# Only run this if we have not hit an entry point yet
if [[ -z "$SZCDF_G__ENTRY_POINT" ]]; then

  if [[ -d "$HOME/.config/szcdf" ]]; then
    export SZCDF_G__ROOT_DIR="$HOME/.config/szcdf"
  elif [[ -d "$HOME/.szcdf" ]]; then
    export SZCDF_G__ROOT_DIR="$HOME/.szcdf"
  fi

  # Only do things if the SZCDF root directory exists
  if [[ -n "$SZCDF_G__ROOT_DIR" ]] && [[ -f "$SZCDF_G__ROOT_DIR/_bootstrap.sh" ]]; then
    # Set up global variables before entering the bootstrap
    if [[ -f "/tmp/SZCDF_G__DEBUG_MODE" ]]; then
      echo "szcdf: Enabling DEBUG MODE"
      export SZCDF_G__DEBUG_MODE=1
    fi
    export SZCDF_G__ENTRY_POINT="${BASH_SOURCE[0]}"
    # Run the bootstrapping, and return 0 if successfully run
    # otherwise, continue running the current script
    if source "$SZCDF_G__ROOT_DIR/_bootstrap.sh"; then
      return 0
    fi
  fi

fi
