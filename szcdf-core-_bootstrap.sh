#!/usr/bin/env bash
###############################################################################
#
# szcdf-core-_bootstrap.sh
# Stephen Zhao

# This script bootstraps the core SZCDF system by
# 1. manually sourcing and initializing the logging module,
# 2. manually sourcing and initializing the module_manager module,
# 3. load the entry module and enter it.

declare -A SZCDF_MODULE__IS_SOURCED
declare -A SZCDF_MODULE__IS_INITED
declare -A SZCDF_MODULE__IS_LOADED

szcdf_bootstrap__try_load_module() {
  local module=$1
  shift
  local script=$1
  shift
  if [[ ! -f "$script" ]]; then
    echo >&2 "Module $module does not exist at '$script'! Cannot bootstrap SZCDF. Aborting..."
    return 1
  fi
  source $script
  SZCDF_MODULE__IS_SOURCED[$module]=1
  szcdf_${module}__init
  SZCDF_MODULE__IS_INITED[$module]=1
  SZCDF_MODULE__IS_LOADED[$module]=1
  return 0
}

# 1. Use the bootstrap loader to load the logging module (since the module manager module isn't loaded yet)
szcdf_bootstrap__try_load_module logging "$SZCDF_G__ROOT_DIR/logging.sh" || return $?

# 2. Use the bootstrap loader to load the module manager module
szcdf_bootstrap__try_load_module module_manager "$SZCDF_G__ROOT_DIR/module_manager.sh" || return $?

# 3. Load the entry module and "exec" it
szcdf_module_manager load configureenv || return $?

# 4. Cleanup before "exec"-ing
unset -f szcdf_bootstrap__try_load_module

szcdf_configureenv

return $?
