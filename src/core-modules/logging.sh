#!/usr/bin/env bash
###############################################################################
#
# szcdf_module
# logging.sh
# Stephen Zhao

# To load this module, run
# szcdf_module_manager load logging

######### INIT ################################################################

# Initializes the logging module
# $# = 0
szcdf_logging__init() {
  declare -a SZCDF_LOGGING__CONTEXT_STACK
  if [[ ${#SZCDF_LOGGING__CONTEXT_STACK[@]} -eq 0 ]]; then
    SZCDF_LOGGING__CONTEXT_STACK[0]=base
  fi
  export SZCDF_LOGGING__CURRENT_CONTEXT="${SZCDF_LOGGING__CONTEXT_STACK[0]}"
}


######### CONTEXT FUNCTIONS ###################################################

# Pushes a new context onto the logging context stack
# $# = 1
# $1 = The name of the new context
szcdf_logging__begin_context() {
  export SZCDF_LOGGING__CURRENT_CONTEXT=$1
  SZCDF_LOGGING__CONTEXT_STACK=( "$1" "${SZCDF_LOGGING__CONTEXT_STACK[@]}" )
}
export -f szcdf_logging__begin_context

# Pops the last context from the logging context stack
# $# = 0
szcdf_logging__end_context() {
  SZCDF_LOGGING__CONTEXT_STACK=( "${SZCDF_LOGGING__CONTEXT_STACK[@]:1}" )
  export SZCDF_LOGGING__CURRENT_CONTEXT="${SZCDF_LOGGING__CONTEXT_STACK[0]}"
}
export -f szcdf_logging__end_context


######### LOGGING LEVEL CONTROL FUNCTIONS #####################################

szcdf_logging__set_level() {
  #TODO: allow setting level
  return 0
}


######### LOGGING FUNCTIONS ###################################################

# Prints a standardized debug message.
# $# = >=0
# $@ = The messages to print.
szcdf_logging__debug() {
  if [[ -n "$SZCDF_G__DEBUG_MODE" && "$SZCDF_G__DEBUG_MODE" == 1 ]]; then
    echo >&2 "[SZCDF][$(date -Iseconds)][DBUG][$SZCDF_LOGGING__CURRENT_CONTEXT] $*"
  fi
}
export -f szcdf_logging__debug

# Prints a standardized info message.
# $# = >=0
# $@ = The messages to print.
szcdf_logging__info() {
  echo >&2 "[SZCDF][$(date -Iseconds)][INFO][$SZCDF_LOGGING__CURRENT_CONTEXT] $*"
}
export -f szcdf_logging__info

# Prints a standardized warning message.
# $# = >=0
# $@ = The messages to print.
szcdf_logging__warning() {
  echo >&2 "$(tput setaf 3)[SZCDF][$(date -Iseconds)][WARN][$SZCDF_LOGGING__CURRENT_CONTEXT] $*$(tput sgr0)"
}
export -f szcdf_logging__warning

# Prints a standardized error message.
# $# = >=0
# $@ = The messages to print.
szcdf_logging__error() {
  echo >&2 "$(tput setaf 1)[SZCDF][$(date -Iseconds)][ERRO][$SZCDF_LOGGING__CURRENT_CONTEXT] $*$(tput sgr0)"
}
export -f szcdf_logging__error


######### CLEANUP ###################################################

# Cleans up all of the functions
szcdf_logging__cleanup() {
  unset -f szcdf_logging__begin_context
  unset -f szcdf_logging__end_context

  unset -f szcdf_logging__set_level

  unset -f szcdf_logging__debug
  unset -f szcdf_logging__info
  unset -f szcdf_logging__warning
  unset -f szcdf_logging__error

  unset -f szcdf_logging__init
  unset -f szcdf_logging__cleanup
}
