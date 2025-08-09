#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: link_syncer
# Purpose: Provides link syncing functionality.
#
# To load this module, run
# ```bash
# szcdf_module_manager load link_syncer
# ```

######### MAIN ################################################################

# $# >= 1
# $1 = ensure_link
# $:2 = additional args depending on subcommand
szcdf_link_syncer() {
  szcdf_logging__begin_context 'szcdf_link_syncer'

  local subcommand=$1
  shift

  case $subcommand in
    ensure_link)
      szcdf_link_syncer__ensure_link "$@"
      ;;
    *)
      szcdf_logging__error "Invalid subcommand: $subcommand"
      ;;
  esac

  szcdf_logging__end_context
}


######### SYNC FUNCTIONS ######################################################

# Syncs the links in the link_sync_dir to the home directory
# $# >= 1
# $1 = link_src_path
# $2 = link_dest_path
szcdf_link_syncer__ensure_link() {
  local link_src_path=$1
  local link_dest_path=$2
  shift
  shift

  szcdf_logging__debug "Ensuring link $link_src_path to $link_dest_path."

  local link_dest_dir
  link_dest_dir=$(dirname "$link_dest_path")
  if [[ ! -d "$link_dest_dir" ]]; then
    szcdf_logging__debug "Creating directory $link_dest_dir."
    mkdir -p "$link_dest_dir"
  fi

  if [[ -L "$link_dest_path" ]]; then
    if [[ "$(readlink "$link_dest_path")" != "$link_src_path" ]]; then
      szcdf_logging__warning "Link $link_dest_path already exists but points to a different path. Moving it to $link_dest_path.old"
      mv "$link_dest_path" "$link_dest_path.old"
    fi
  elif [[ -e "$link_dest_path" ]]; then
    szcdf_logging__warning "Link $link_dest_path already exists and is not a link. Moving it to $link_dest_path.old"
    mv "$link_dest_path" "$link_dest_path.old"
  fi

  szcdf_logging__debug "Linking $link_src_path to $link_dest_path."
  ln -sf "$link_src_path" "$link_dest_path"

  szcdf_logging__debug "Finished syncing link $link_src_path to $link_dest_path."
}


######### CLEANUP #############################################################

# $# = 0
szcdf_link_syncer__cleanup() {
  unset -f szcdf_link_syncer

  unset -f szcdf_link_syncer__ensure_link

  unset -f szcdf_link_syncer__cleanup
}
