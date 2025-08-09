#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: preset
# Purpose: Can be used to define and handle presets.
#
# To load this module, run
# ```bash
# szcdf_module_manager load preset
# ```

######### MAIN ################################################################

# $# >= 1
# $1 = register | load_all_registered | is_loaded
# $:2 = additional args depending on subcommand
szcdf_preset() {
  szcdf_logging__begin_context 'szcdf_preset'

  local subcommand=$1
  shift

  case $subcommand in
    register)
      szcdf_preset__register "$@"
      ;;
    load_all_registered)
      szcdf_preset__load_all_registered
      ;;
    is_loaded)
      szcdf_preset__is_loaded "$@"
      ;;
    *)
      szcdf_logging__warning "Invalid arguments: $*"
      szcdf_preset__usage
  esac

  szcdf_logging__end_context
}


######### INIT ################################################################

# Initializes the preset module
# $# = 0
szcdf_preset__init() {
  declare -A SZCDF_PRESET__IS_REGISTERED
  declare -a SZCDF_PRESET__REGISTERED_PRESETS
  declare -A SZCDF_PRESET__IS_REGISTERED_AS_DIR
  declare -A SZCDF_PRESET__IS_REGISTERED_AS_SINGLE_SCRIPT

  declare -A SZCDF_PRESET__IS_LOADED
  declare -a SZCDF_PRESET__LOADED_PRESETS

  declare -A SZCDF_PRESET__HAD_FAILURE
}


######### REGISTRATION ########################################################

# Registers the given preset
# $# = 1
# $1 = the name of the preset to register
# Export: szcdf_preset register $1
szcdf_preset__register() {
  # Check if arg exists
  if [[ -z "$1" ]]; then
    szcdf_logging__warning "No preset specified. Skipping."
    return
  fi
  local preset_name=$1
  shift
  # Check if preset is already registered
  if [[ "${SZCDF_PRESET__IS_REGISTERED[$preset_name]+_}" == 1 ]]; then
    szcdf_logging__warning "Preset '$preset_name' is already registered. Skipping."
    return
  fi
  # Check if preset dir exists
  local preset_dir="$SZCDF_G__ROOT_DIR/presets/$preset_name" 
  local preset_single_script="$SZCDF_G__ROOT_DIR/presets/${preset_name}.sh" 
  if [[ -d  "$preset_dir" ]]; then
    szcdf_logging__debug "Registering preset '$preset_name' as directory..."
    # Enqueue the preset for processing
    SZCDF_PRESET__REGISTERED_PRESETS=( "${SZCDF_PRESET__REGISTERED_PRESETS[@]}" "$preset_name" )
    SZCDF_PRESET__IS_REGISTERED_AS_DIR[$preset_name]=1
    SZCDF_PRESET__IS_REGISTERED[$preset_name]=1
  elif [[ -f  "$preset_single_script" ]]; then
    szcdf_logging__debug "Registering preset '$preset_name' as single script..."
    # Enqueue the preset for processing
    SZCDF_PRESET__REGISTERED_PRESETS=( "${SZCDF_PRESET__REGISTERED_PRESETS[@]}" "$preset_name" )
    SZCDF_PRESET__IS_REGISTERED_AS_SINGLE_SCRIPT[$preset_name]=1
    SZCDF_PRESET__IS_REGISTERED[$preset_name]=1
  else
    szcdf_logging__warning "Preset '$preset_name' must have a dir at \"$preset_dir\" or a single script at \"$preset_single_script\". Skipping."
    return
  fi
  szcdf_logging__debug "Finished registering preset '$preset_name'."
}


######### LOADING #############################################################

# Loads all of the registered presets, in load order
# $# = 0
# Export: szcdf_preset load_all_registered
szcdf_preset__load_all_registered() {
  # Check if any presets are prepared
  if [[ ${#SZCDF_PRESET__REGISTERED_PRESETS[@]} -eq 0 ]]; then
    szcdf_logging__info "No presets registered."
    return
  fi

  # Load all registered presets
  szcdf_logging__debug "Loading all registered presets..."
  
  # Step 1: Before Loading Any Presets
  szcdf_logging__debug "Running before-any-load scripts for all registered presets..."
  for preset_name in "${SZCDF_PRESET__REGISTERED_PRESETS[@]}"; do
    # Skip all empty names
    if [[ -z "$preset_name" ]]; then
      continue
    fi
    # Skip all presets that are registered as single scripts
    if [[ ${SZCDF_PRESET__IS_REGISTERED_AS_SINGLE_SCRIPT[$preset_name]+_} ]]; then
      continue
    fi
    # Run the pre-any-load scripts
    szcdf_preset__run_load_stage "$preset_name" 1 'before-any-load'
  done
  szcdf_logging__debug "Finished running before-any-load scripts for all registered presets."

  # Step 2: Load Presets
  szcdf_logging__debug "Running on-load scripts for all registered presets..."
  for preset_name in "${SZCDF_PRESET__REGISTERED_PRESETS[@]}"; do
    # Skip all empty names
    if [[ -z "$preset_name" ]]; then
      continue
    fi
    # If the preset is registered as a single script, load it directly
    if [[ ${SZCDF_PRESET__IS_REGISTERED_AS_SINGLE_SCRIPT[$preset_name]+_} ]]; then
      szcdf_preset__run_load_single_script "$preset_name"
    # Otherwise, run the on-load scripts
    else
      szcdf_preset__run_load_stage "$preset_name" 2 'on-load'
    fi
  done
  szcdf_logging__debug "Finished running on-load scripts for all registered presets."

  # Step 3: After Loading All Presets
  szcdf_logging__debug "Running after-all-load scripts for all registered presets..."
  for preset_name in "${SZCDF_PRESET__REGISTERED_PRESETS[@]}"; do
    # Skip all empty names
    if [[ -z "$preset_name" ]]; then
      continue
    fi
    # Skip all presets that are registered as single scripts
    if [[ ${SZCDF_PRESET__IS_REGISTERED_AS_SINGLE_SCRIPT[$preset_name]+_} ]]; then
      continue
    fi
    # Run the post-all-load scripts
    szcdf_preset__run_load_stage "$preset_name" 3 'after-all-load'
  done
  szcdf_logging__debug "Finished running after-all-load scripts for all registered presets."

  # Step 4: Mark all successfully loaded presets as loaded
  for preset_name in "${SZCDF_PRESET__REGISTERED_PRESETS[@]}"; do
    if [[ ! ${SZCDF_PRESET__HAD_FAILURE[$preset_name]+_} ]]; then
      szcdf_preset__mark_loaded "$preset_name"
    fi
  done

  szcdf_logging__debug "Finished loading all registered presets."
}

# PRIVATE: Runs the single-script load script for a given preset
# $# = 1
# $1 = the name of the preset
szcdf_preset__run_load_single_script() {
  # Check if arg exists
  if [[ -z "$1" ]]; then
    szcdf_logging__warning "No preset specified. Skipping."
    return
  fi
  local preset_name=$1
  shift
  # Check to make sure the preset has not been fully loaded yet
  if [[ ${SZCDF_PRESET__IS_LOADED[$preset_name]+_} ]]; then
    szcdf_logging__debug "Preset '$preset_name' is loaded. Skipping load script."
    return
  fi
  # Check to make sure the preset hasn't hit had any failures
  if [[ ${SZCDF_PRESET__HAD_FAILURE[$preset_name]+_} ]]; then
    return 1
  fi
  # Source the load script
  if ! source "$SZCDF_G__ROOT_DIR/presets/${preset_name}.sh"; then
    SZCDF_PRESET__HAD_FAILURE[$preset_name]=1
    szcdf_logging__warning "Encountered failure when running load script for preset '$preset_name'. Skipping this preset."
    return 1
  fi
  szcdf_logging__debug "Finished running load script for preset '$preset_name'."
}

# PRIVATE: Runs the directory-based load script for a given preset and stage
# $# = 2
# $1 = the name of the preset
# $2 = the number of the stage
# $3 = the name of the stage
szcdf_preset__run_load_stage() {
  # Check if arg exists
  if [[ -z "$1" ]]; then
    szcdf_logging__warning "No preset specified. Skipping."
    return
  fi
  local preset_name=$1
  shift
  local load_stage_num=$1
  shift
  local load_stage_name=$1
  shift
  # Check to make sure the preset has not been fully loaded yet
  if [[ ${SZCDF_PRESET__IS_LOADED[$preset_name]+_} ]]; then
    szcdf_logging__debug "Preset '$preset_name' is loaded. Skipping $load_stage_name (load stage $load_stage_num) scripts."
    return
  fi
  # Check to make sure the preset hasn't hit had any failures
  if [[ ${SZCDF_PRESET__HAD_FAILURE[$preset_name]+_} ]]; then
    return 1
  fi
  # Check if preset dir exists and set it
  local preset_dir="$SZCDF_G__ROOT_DIR/presets/$preset_name" 
  if [[ ! -d  "$preset_dir" ]]; then
    szcdf_logging__warning "Preset '$preset_name' must have a dir at \"$preset_dir\". Skipping $load_stage_name (load stage $load_stage_num) scripts."
    return 1
  fi
  # For each script in the stage, run it
  szcdf_logging__debug "Running $load_stage_name (load stage $load_stage_num) scripts for preset '$preset_name'..."
  for script in "$preset_dir"/"${load_stage_num}"*.sh; do
    if [[ ! -f "$script" ]]; then
      continue
    elif ! source "$script"; then
      SZCDF_PRESET__HAD_FAILURE[$preset_name]=1
      szcdf_logging__warning "Encountered failure when running $load_stage_name (load stage $load_stage_num) script for preset '$preset_name'. Skipping this preset."
      return 1
    fi
  done
  szcdf_logging__debug "Finished running $load_stage_name (load stage $load_stage_num) scripts for preset '$preset_name'."
}

# PRIVATE: Marks the specified preset as fully loaded
# $# = 1
# $1 = the name of the preset that was loaded
szcdf_preset__mark_loaded() {
  local preset_name=$1
  shift
  SZCDF_PRESET__LOADED_PRESETS=( "${SZCDF_PRESETS_LOADED[@]}" "$preset_name" )
  SZCDF_PRESET__IS_LOADED[$preset_name]=1
}

# $# = 1
# $1 = Name of module to check
# Stdout: 1 if a module is loaded
# Return: 0 if loaded, 1 otherwise
szcdf_preset__is_loaded() {
  # Check if arg exists
  if [[ -z "$1" ]]; then
    szcdf_logging__warning "No preset specified. Skipping."
    return
  fi
  local preset_name=$1
  shift

  if [[ "${SZCDF_PRESET__LOADED_PRESETS[$preset_name]+_}" ]]; then
    echo 1
    return 0
  else
    return 1
  fi
}


######### USAGE ###############################################################

# Displays usage
szcdf_preset__usage() {
  echo >&2 "Usage: szcdf_preset { register | load_all_registered | is_loaded } [args...]"
}

######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_preset__cleanup() {
  unset -f szcdf_preset

  unset -f szcdf_preset__register

  unset -f szcdf_preset__run_load_single_script
  unset -f szcdf_preset__run_load_stage
  unset -f szcdf_preset__mark_loaded
  
  unset -f szcdf_preset__is_loaded

  unset -f szcdf_preset__usage

  unset -f szcdf_preset__init
  unset -f szcdf_preset__cleanup
}
