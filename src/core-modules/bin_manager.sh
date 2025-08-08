#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Module
# Module: bin_manager
# Purpose: Manages user-invocable scripts under bin by importing them
#          into ~/.local/bin so they are available on $PATH.
#
# To load this module, run
# ```bash
# szcdf_module_manager load bin_manager
# ```

######### MAIN ################################################################

# $# >= 1
# $1 = list | import | import_all | remove | clean
# $[2:*] = additional args depending on subcommand
szcdf_bin_manager() {
  szcdf_logging__begin_context 'szcdf_bin_manager'

  local subcommand=$1
  shift

  case $subcommand in
    list)
      szcdf_bin_manager__list "$@"
      ;;
    import)
      szcdf_bin_manager__import "$@"
      ;;
    import_all)
      szcdf_bin_manager__import_all
      ;;
    remove)
      szcdf_bin_manager__remove "$@"
      ;;
    clean)
      szcdf_bin_manager__clean
      ;;
    *)
      szcdf_logging__warning "Invalid arguments: $*"
      szcdf_bin_manager__usage
      ;;
  esac

  szcdf_logging__end_context
}


######### INIT ################################################################

# Initializes the bin_manager module
# $# = 0
szcdf_bin_manager__init() {
  declare -A SZCDF_BIN_MANAGER__IS_IMPORTED

  # Ensure destination bin directory exists and is on PATH
  local dest_bin_dir
  dest_bin_dir="$(szcdf_bin_manager__get_dest_bin_dir)"
  if [[ ! -d "$dest_bin_dir" ]]; then
    mkdir -p "$dest_bin_dir"
  fi
  case ":$PATH:" in
    *":$dest_bin_dir:"*)
      ;;
    *)
      export PATH="$dest_bin_dir:$PATH"
      szcdf_logging__debug "Added '$dest_bin_dir' to PATH."
      ;;
  esac
}


######### HELPERS ##############################################################

szcdf_bin_manager__get_src_bin_dir() {
  echo "$SZCDF_G__ROOT_DIR/bin"
}

szcdf_bin_manager__get_dest_bin_dir() {
  echo "$HOME/.local/bin"
}


######### SUBCOMMANDS #########################################################

# Lists available scripts found in $SZCDF_G__ROOT_DIR/bin
# $# = 0
szcdf_bin_manager__list() {
  local scripts_dir
  scripts_dir="$(szcdf_bin_manager__get_src_bin_dir)"

  if [[ ! -d "$scripts_dir" ]]; then
    szcdf_logging__info "No scripts directory found at '$scripts_dir'."
    return 0
  fi

  local found_any=0
  for script_path in "$scripts_dir"/*; do
    if [[ -f "$script_path" ]]; then
      echo "$(basename "$script_path")"
      found_any=1
    fi
  done
  if [[ $found_any -eq 0 ]]; then
    szcdf_logging__info "No scripts found in '$scripts_dir'."
  fi
}

# Imports a single script into ~/.local/bin via symlink
# $# = 1
# $1 = script file name inside bin (basename)
szcdf_bin_manager__import() {
  if ! declare -p SZCDF_BIN_MANAGER__IS_IMPORTED >/dev/null 2>&1; then
    declare -A SZCDF_BIN_MANAGER__IS_IMPORTED
  fi
  local script_name=$1
  shift || true

  if [[ -z "$script_name" ]]; then
    szcdf_logging__warning "No script specified. Usage: szcdf_bin_manager import <script_name>"
    return 1
  fi

  local scripts_dir
  scripts_dir="$(szcdf_bin_manager__get_src_bin_dir)"
  local src_path="$scripts_dir/$script_name"

  if [[ ! -f "$src_path" ]]; then
    szcdf_logging__warning "Script '$script_name' not found at '$src_path'."
    return 1
  fi

  local bin_dir
  bin_dir="$(szcdf_bin_manager__get_dest_bin_dir)"
  local dest_path="$bin_dir/$script_name"

  if [[ ! -d "$bin_dir" ]]; then
    mkdir -p "$bin_dir"
  fi

  # Ensure source is executable for direct invocation
  if [[ ! -x "$src_path" ]]; then
    chmod u+x "$src_path"
  fi

  if [[ -e "$dest_path" ]] && [[ ! -L "$dest_path" ]]; then
    szcdf_logging__warning "Destination '$dest_path' exists and is not a symlink. Skipping."
    return 1
  fi

  if [[ -L "$dest_path" ]]; then
    local current_target
    current_target="$(readlink -f "$dest_path")"
    if [[ "$current_target" == "$src_path" ]]; then
      szcdf_logging__debug "Symlink '$dest_path' already points to '$src_path'. Skipping."
      SZCDF_BIN_MANAGER__IS_IMPORTED["$script_name"]=1
      return 0
    else
      szcdf_logging__warning "Symlink '$dest_path' points to a different target ($current_target). Skipping."
      return 1
    fi
  fi

  ln -s "$src_path" "$dest_path"
  SZCDF_BIN_MANAGER__IS_IMPORTED["$script_name"]=1
  szcdf_logging__info "Imported script '$script_name' to '$dest_path'."
}

# Imports all scripts from bin
# $# = 0
szcdf_bin_manager__import_all() {
  local scripts_dir
  scripts_dir="$(szcdf_bin_manager__get_src_bin_dir)"

  if [[ ! -d "$scripts_dir" ]]; then
    szcdf_logging__info "No scripts directory found at '$scripts_dir'. Nothing to import."
    return 0
  fi

  local had_any=0
  for script_path in "$scripts_dir"/*; do
    if [[ -f "$script_path" ]]; then
      had_any=1
      szcdf_bin_manager__import "$(basename "$script_path")"
    fi
  done
  if [[ $had_any -eq 0 ]]; then
    szcdf_logging__info "No scripts found in '$scripts_dir'."
  fi
}

# Removes a single imported script symlink from ~/.local/bin
# $# = 1
# $1 = script file name (basename)
szcdf_bin_manager__remove() {
  local script_name=$1
  shift || true

  if [[ -z "$script_name" ]]; then
    szcdf_logging__warning "No script specified. Usage: szcdf_bin_manager remove <script_name>"
    return 1
  fi

  local scripts_dir
  scripts_dir="$(szcdf_bin_manager__get_src_bin_dir)"
  local bin_dir
  bin_dir="$(szcdf_bin_manager__get_dest_bin_dir)"
  local dest_path="$bin_dir/$script_name"

  if [[ ! -e "$dest_path" ]]; then
    szcdf_logging__warning "No file found at '$dest_path'. Skipping."
    return 0
  fi

  if [[ -L "$dest_path" ]]; then
    local current_target
    current_target="$(readlink -f "$dest_path")"
    # Only remove if it points into our scripts dir (safety)
    if [[ "$current_target" == "$scripts_dir/$script_name" ]]; then
      rm "$dest_path"
      unset 'SZCDF_BIN_MANAGER__IS_IMPORTED[$script_name]'
      szcdf_logging__info "Removed imported script '$script_name' from '$dest_path'."
      return 0
    fi
  fi

  szcdf_logging__warning "'$dest_path' is not a managed symlink. Skipping."
  return 1
}

# Cleans up broken symlinks in ~/.local/bin pointing into bin
# $# = 0
szcdf_bin_manager__clean() {
  local scripts_dir
  scripts_dir="$(szcdf_bin_manager__get_src_bin_dir)"
  local bin_dir
  bin_dir="$(szcdf_bin_manager__get_dest_bin_dir)"

  if [[ ! -d "$bin_dir" ]]; then
    return 0
  fi

  local cleaned_any=0
  local entry
  for entry in "$bin_dir"/*; do
    if [[ -L "$entry" ]]; then
      local target
      target="$(readlink -f "$entry")"
      if [[ "$target" == "$scripts_dir"/* ]] && [[ ! -e "$target" ]]; then
        rm "$entry"
        cleaned_any=1
        szcdf_logging__info "Removed broken symlink '$entry' -> '$target'."
      fi
    fi
  done

  if [[ $cleaned_any -eq 0 ]]; then
    szcdf_logging__debug "No broken managed symlinks found to clean."
  fi
}


######### USAGE ###############################################################

szcdf_bin_manager__usage() {
  echo >&2 "Usage: szcdf_bin_manager { list | import <script_name> | import_all | remove <script_name> | clean }"
}


######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_bin_manager__cleanup() {
  unset -f szcdf_bin_manager

  unset -f szcdf_bin_manager__list
  unset -f szcdf_bin_manager__import
  unset -f szcdf_bin_manager__import_all
  unset -f szcdf_bin_manager__remove
  unset -f szcdf_bin_manager__clean

  unset -f szcdf_bin_manager__get_src_bin_dir
  unset -f szcdf_bin_manager__get_dest_bin_dir

  unset -f szcdf_bin_manager__usage

  unset -f szcdf_bin_manager__init
  unset -f szcdf_bin_manager__cleanup
}


