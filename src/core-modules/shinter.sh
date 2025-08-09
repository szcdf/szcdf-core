#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: shinter
# Purpose: Determines the interactivity of the shell.
#
# To load this module, run
# ```bash
# szcdf_module_manager load shinter
# ```

######### MAIN ################################################################

szcdf_shinter() {
  szcdf_logging__begin_context 'szcdf_shinter'

  local subcommand=$1
  shift

  case $subcommand in
    detect_is_interactive)
      szcdf_shinter__detect_is_interactive
      ;;
    detect_and_set_is_interactive)
      szcdf_shinter__detect_and_set_is_interactive
      ;;
    return_is_interactive)
      szcdf_shinter__return_is_interactive
      ;;
    *)
      szcdf_logging__warning "Invalid args: $*"
      ;;
  esac

  szcdf_logging__end_context
}


######### SUBCOMMANDS #########################################################

# $# = 0
# stdout = whether the shell is interactive or not (Y or empty)
szcdf_shinter__detect_is_interactive() {
  # Check interactivity
  if [[ $- == *i* ]]; then
    echo Y
    return 0
  else
    return 1
  fi
}

# $# = 0
szcdf_shinter__detect_and_set_is_interactive() {
    szcdf_shinter__IS_INTERACTIVE=$(szcdf_shinter__detect_is_interactive)
    export szcdf_shinter__IS_INTERACTIVE
}

# $# = 0
# $? = 0 if interactive, 1 if not
szcdf_shinter__return_is_interactive() {
  if [[ -z "$szcdf_shinter__IS_INTERACTIVE" ]]; then
    szcdf_shinter__detect_and_set_is_interactive
  fi
  if [[ -n "$szcdf_shinter__IS_INTERACTIVE" ]]; then
    return 0
  else
    return 1
  fi
}

######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_shinter__cleanup() {
  unset -f szcdf_shinter

  unset -f szcdf_shinter__detect_is_interactive
  unset -f szcdf_shinter__detect_and_set_is_interactive
  unset -f szcdf_shinter__return_is_interactive

  unset -f szcdf_shinter__cleanup
}
