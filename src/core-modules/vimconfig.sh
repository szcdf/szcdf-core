#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: vimconfig
# Purpose: Manage vim settings.
#
# To load this module, run
# ```bash
# szcdf_module_manager load vimconfig
# ```

# This is a module to control & manage vim settings

######### MAIN ################################################################

szcdf_vimconfig() {
  szcdf_logging__begin_context "szcdf_vimconfig"

  local subcommand=$1
  shift

  case $subcommand in
    install-configs)
      szcdf_vimconfig__install_configs
      ;;
    *)
      szcdf_logging__warning "Invalid args: $@"
      ;;
  esac

  szcdf_logging__end_context
}


######### SUBCOMMANDS #########################################################

# $# = 0
szcdf_vimconfig__install_configs() {
  SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR=
  
  # Check to see if vim is even installed
  if ! command -v vim &> "/dev/null"; then
    SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR="vim not installed. Skipping preset..."
    szcdf_logging__warning $SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR
    return
  fi

  # Validate directories are free to install into
  # else create them
  if [[ -f "$HOME/.vim" ]]; then
    SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR="~/.vim exists, but is a regular file. Cannot load preset!"
    szcdf_logging__error $SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR
    return
  elif [[ -d "$HOME/.vim" ]]; then
    :
  else
    mkdir "$HOME/.vim"
  fi
  if [[ -f "$HOME/.vim/bundle" ]]; then
    SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR="~/.vim/bundle exists, but is a regular file. Cannot load preset!"
    szcdf_logging__error $SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR
    return
  elif [[ -d "$HOME/.vim/bundle" ]]; then
    :
  else
    mkdir "$HOME/.vim/bundle"
  fi
  # Check to see if Vundle is already installed
  if [[ -e "$HOME/.vim/bundle/Vundle.vim" ]]; then
    szcdf_logging__debug "Vundle is already installed."
  else
    # If not, clone it from GitHub
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
  fi
  
  # === Update the vimrc target ===

  # First, determine the old target, if one exists
  local vimrc_old_target
  if [[ -e "$HOME/.vim/vimrc" ]]; then
    vimrc_old_target=$(readlink "$HOME/.vim/vimrc")
  else
    vimrc_old_target=''
  fi
  szcdf_logging__debug "vimrc_old_target is '$vimrc_old_target'"

  # Then, determine the new target, if one exists
  local vimrc_new_target
  # Check to see if a SZCDF_PROFILE_NAME is set, and if a profile-specific .vimrc exists
  if [[ -n "$SZCDF_PROFILE_NAME" && -e "$SZCDF_G__ROOT_DIR/vimconfig/profile.d/$SZCDF_PROFILE_NAME/vimrc" ]]; then
    vimrc_new_target="$SZCDF_G__ROOT_DIR/vimconfig/profile.d/$SZCDF_PROFILE_NAME/vimrc"
  elif [[ -e "$SZCDF_G__ROOT_DIR/vimconfig/vimrc" ]]; then
    vimrc_new_target="$SZCDF_G__ROOT_DIR/vimconfig/vimrc"
  else
    vimrc_new_target="$vimrc_old_target"
  fi
  szcdf_logging__debug "vimrc_new_target is '$vimrc_new_target'"

  local vimrc_target_changed
  # Update the target based on the values of old and new
  if [[ -z "$vimrc_new_target" ]]; then
    if [[ -z "$vimrc_old_target" ]]; then
      # Both old and new targets empty, preset cannot be loaded
      SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR="No vimrc found. The szcdf_vimconfig module must be corrupted. Cannot load preset! Please reinstall."
      szcdf_logging__error "$SZCDF_VIMCONFIG__INSTALL_CONFIGS_ERROR"
      return
    else
      # Only new target is empty, so just fallback load the preset using the old target
      szcdf_logging__warning "No vimrc found. The szcdf_vim module must be corrupted. Continuuing using existing .vimrc."
      vimrc_target_changed=
    fi
  else
    if [[ -n "$vimrc_old_target" && "$vimrc_old_target" != "$vimrc_new_target" ]]; then
      # Both targets exist, and targets are different, so delete old one first
      szcdf_logging__warning "~/.vim/vimrc exists. Relinking to point to new .vimrc based on profile."
      szcdf_logging__warning "OLD TARGET = $vimrc_old_target"
      szcdf_logging__warning "NEW TARGET = $vimrc_new_target"
      rm "$HOME/.vim/vimrc"
      ln -vs "$vimrc_new_target" "$HOME/.vim/vimrc"
      vimrc_target_changed=True
    elif [[ -n "$vimrc_old_target" ]]; then
      # Both targets exist, but point to the same one so skip.
      szcdf_logging__debug "~/.vim/vimrc found and already points to current profile."
      vimrc_target_changed=
    else
      # Only new target exists
      szcdf_logging__debug "~/.vim/vimrc not found. Linking new one based on profile."
      ln -vs "$vimrc_new_target" "$HOME/.vim/vimrc"
      vimrc_target_changed=True
    fi
  fi

  # === Check last loaded profile ===

  # Check if we changed profile from the last loading
  local vimrc_lastprofile_file="$SZCDF_G__ROOT_DIR/vimconfig/lastprofile"
  local vimrc_lastprofile_changed
  if [[ ! -e "$vimrc_lastprofile_file" || "$(cat $vimrc_lastprofile_file)" != "$SZCDF_PROFILE_NAME" ]]; then
    szcdf_logging__info "Detected change in profile."
    echo $SZCDF_PROFILE_NAME > $vimrc_lastprofile_file
    vimrc_lastprofile_changed=True
  else
    vimrc_lastprofile_changed=
  fi
  
  # === Install Vundle Bundles ===

  # Check if we changed our .vimrc or if our profile changed, only install in that case
  if [[ -n "$vimrc_target_changed" || -n "$vimrc_lastprofile_changed" ]]; then
    szcdf_logging__info "Running Vundle plugin install..."
    echo | echo | vim +PluginInstall +qall > /dev/null
    szcdf_logging__info "Finished Vundle plugin install."
  fi
}


######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_vimconfig__cleanup() {
  unset -f szcdf_vimconfig

  unset -f szcdf_vimconfig__install_configs

  unset -f szcdf_vimconfig__cleanup
}
