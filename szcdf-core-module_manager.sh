#!/usr/bin/env bash
###############################################################################
#
# szcdf-core-module_manager.sh
# Stephen Zhao

# This is a module that manages the use of modules.


######### MAIN ################################################################

# $# >= 1
# $1 = load | is_loaded | unload_all_loaded
# $[2:*] = additional args depending on subcommand
szcdf_module_manager() {
  szcdf_logging__begin_context "szcdf_module_manager"

  local subcommand=$1
  shift

  case $subcommand in
    load)
      szcdf_module_manager__load "$@"
      ;;
    is_loaded)
      szcdf_module_manager__is_loaded "$@"
      ;;
    unload_all_loaded)
      szcdf_module_manager__unload_all_loaded
      ;;
    *)
      szcdf_logging__error "Invalid subcommand $subcommand"
      ;;
  esac

  szcdf_logging__end_context
}


######### INIT ################################################################

# Initializes the module manager module
# $# = 0
szcdf_module_manager__init() {
  declare -A SZCDF_MODULE__IS_SOURCING
  declare -A SZCDF_MODULE__IS_SOURCED

  declare -A SZCDF_MODULE__IS_INITING
  declare -A SZCDF_MODULE__IS_INITED

  declare -A SZCDF_MODULE__IS_LOADING
  declare -A SZCDF_MODULE__IS_LOADED

  if [[ -z "$SZCDF_MODULES_LOADED" ]]; then
    SZCDF_MODULES_LOADED=( module_manager )
  else
    SZCDF_MODULES_LOADED=( module_manager "${SZCDF_MODULES_LOADED[@]}" )
  fi
}


######### SUBCOMMANDS #########################################################


# Checks if a specified module is loaded
# $# = 1
# $1 = Name of module to check
# Stdout: 1 if a module is loaded
# Return: 0 if loaded, 1 otherwise
szcdf_module_manager__is_loaded() {
  local module
  module=$1
  if [[ "${SZCDF_MODULE__IS_LOADED[$module]+_}" ]]; then
    echo 1
    return 0
  else
    return 1
  fi
}


# Loads the specified module
# $# = 1 or 2
# $1 = Name of module to be sourced
# $2 = (Optional) path to the module's main script
# Export: szcdf_module_manager load $1 [$2]
szcdf_module_manager__load() {
  #TODO: Check if module manager itself is inited

  local module=$1
  shift
  local path
  local script

  # Check if the module is already loaded
  if [[ ${SZCDF_MODULE__IS_LOADED[$module]+_} ]] || [[ ${SZCDF_MODULE__IS_LOADING[$module]+_} ]]; then
    szcdf_logging__warning "Module $module is already loaded. Skipping"
    return 1
  fi
  
  # If optional path parameter exists, try to use it
  if [[ -n "$1" ]]; then
    path=$1
    shift
    szcdf_logging__debug "Checking if module $module exists at custom path $path..."
    if [[ ! -f "$path" ]]; then
      szcdf_logging__warning "Module $module does not exist at '$path'! Falling back to standard location..."
    else
      script=$path
    fi
  fi
  
  # If no optional path parameter or path was bad, use default location
  if [[ -n "$script" ]]; then
    path="$SZCDF_G__ROOT_DIR/$module.sh"
    szcdf_logging__debug "Checking if module $module exists..."
    if [[ ! -f "$path" ]]; then
      szcdf_logging__error "Module $module does not exist at '$path'! Aborting..."
      return 1
    else
      script=$path
    fi
  fi

  szcdf_logging__debug "Module $module found."

  SZCDF_MODULE__IS_LOADING[$module]=1
  
  # Source the module's script
  szcdf_logging__debug "Checking if module $module is sourced..."
  if [[ ${SZCDF_MODULE__IS_SOURCED[$module]+_} ]] || [[ ${SZCDF_MODULE__IS_SOURCING[$module]+_} ]]; then
    szcdf_logging__debug "Module $module is already sourced. Skipping source..."
  else
    szcdf_logging__debug "Module $module is not yet sourced, so sourcing now..."
    SZCDF_MODULE__IS_SOURCING[$module]=1
    source "$script"
    SZCDF_MODULE__IS_SOURCED[$module]=1
    unset 'SZCDF_MODULE__IS_SOURCING[$module]'
    szcdf_logging__debug "Finished sourcing module $module."
  fi

  # Run init function if it exists
  szcdf_logging__debug "Checking if module $module needs to be inited..."
  if [[ ${SZCDF_MODULE__IS_INITED[$module]+_} ]] || [[ ${SZCDF_MODULE__IS_INITING[$module]+_} ]]; then
    szcdf_logging__debug "Module $module is already inited. Skipping init..."
  else
    szcdf_logging__debug "Module $module needs to be inited."

    szcdf_logging__debug "Checking if module $module has an init function..."
    if [[ "$(type -t szcdf_"$module"__init)" != 'function' ]]; then
      szcdf_logging__debug "Module $module does not have an init function. Skipping init..."
    else
      szcdf_logging__debug "Initializing module $module..."
      SZCDF_MODULE__IS_INITING[$module]=1
      szcdf_"$module"__init
      SZCDF_MODULE__IS_INITED[$module]=1
      unset 'SZCDF_MODULE__IS_INITING[$module]'
      szcdf_logging__debug "Finished initializing module $module."
    fi
  fi

  # Mark module as loaded and push onto stack of loaded modules
  SZCDF_MODULE__IS_LOADED[$module]=1
  unset 'SZCDF_MODULE__IS_LOADING[$module]'
  SZCDF_MODULES_LOADED=( "$module" "${SZCDF_MODULES_LOADED[@]}" )
}

# Unloads all loaded modules in reverse order of load.
# $# = 0
# Export: szcdf_module_manager unload_all_loaded
szcdf_module_manager__unload_all_loaded() {
  while [[ ${SZCDF_MODULES_LOADED[0]+_} ]]; do
    local module="${SZCDF_MODULES_LOADED[0]}"
    szcdf_module_manager__unload_impl
    SZCDF_MODULES_LOADED=("${SZCDF_MODULES_LOADED[@]:1}")
  done
}

# PRIVATE: Unloads a specified module
# $# = 0
# Assumes $module is in scope
szcdf_module_manager__unload_impl() {
  # Check if module is even loaded before trying to unload
  if [[ ! ${SZCDF_MODULE__IS_LOADED[$module]+_} ]]; then
    return 1
  fi

  # Run optional cleanup function for the module
  if [[ "$(type -t szcdf_"$module"__cleanup)" != 'function' ]]; then
    szcdf_logging__debug "Cleanup function does not exist for module $module. Skipping cleanup..."
  else
    szcdf_logging__debug "Cleaning up module $module..."
    szcdf_"$module"__cleanup
    szcdf_logging__debug "Finished cleaning up module $module."
  fi

  # Mark as unloaded
  unset 'SZCDF_MODULE__IS_INITED[$module]'
  unset 'SZCDF_MODULE__IS_SOURCED[$module]'
  unset 'SZCDF_MODULE__IS_LOADED[$module]'
}


######### CLEANUP #############################################################

# $# = 0
szcdf_module__cleanup() {
  unset -f szcdf_module_manager

  unset -f szcdf_module_manager__load
  unset -f szcdf_module_manager__is_loaded
  unset -f szcdf_module_manager__unload_all_loaded
  unset -f szcdf_module_manager__unload_impl

  unset -f szcdf_module_manager__init
  unset -f szcdf_module_manager__cleanup
}
