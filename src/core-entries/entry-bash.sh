#!/bin/bash
###############################################################################
#
# szcdf-entry-bash.sh
# Stephen Zhao

# Only run this if we have not hit an entry point yet
if [[ -z "$SZC_G__ENTRY_POINT" ]]; then

  if [[ -d "$HOME/.config/szcdf" ]]; then
    export SZC_G__ROOT_DIR="$HOME/.config/szcdf"
  elif [[ -d "$HOME/.szcdf" ]]; then
    export SZC_G__ROOT_DIR="$HOME/.szcdf"
  fi

  # Only do things if the SZCDF root directory exists
  if [[ -n "$SZC_G__ROOT_DIR" ]] && [[ -f "$SZC_G__ROOT_DIR/_bootstrap.sh" ]]; then
    # Set up global variables before entering the bootstrap
    if [[ -f "/tmp/szc_g__debug_flag" ]]; then
      export SZC_G__DEBUG_MODE=1
    fi
    export SZC_G__ENTRY_POINT="${BASH_SOURCE[0]}"
    # Run the bootstrapping, and return 0 if successfully run
    # otherwise, continue running the current script
    if source "$SZC_G__ROOT_DIR/_bootstrap.sh"; then
      return 0
    fi
  fi

fi