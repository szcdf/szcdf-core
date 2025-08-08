#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Module
# Module: profile
# Purpose: Can be used to define and handle profiles.
#
# To load this module, run
# ```bash
# szcdf_module_manager load profile
# ```

######### MAIN ################################################################

# $# = 1
# $1 = detect | load | detect_and_load | get
szcdf_profile() {
  szcdf_logging__begin_context 'szcdf_profile'

  local subcommand=$1
  shift

  case $subcommand in
    detect)
      szcdf_profile__detect
      ;;
    get)
      szcdf_profile__get
      ;;
    load)
      szcdf_profile__load "$@"
      ;;
    detect_and_load)
      szcdf_profile__detect_and_load
      ;;
    *)
      szcdf_logging__warning "Invalid subcommand: $subcommand"
      szcdf_profile__usage
  esac

  szcdf_logging__end_context
}


######### SUBCOMMANDS #########################################################

# Determines and prints the profile name
# $# = 0
# stdout = the profile name
szcdf_profile__detect() {
  szcdf_logging__debug "Determining settings profile..."
  local settings_profile
  for profile_dir in "$SZCDF_G__ROOT_DIR"/profile.d/*; do
    # Check if profile dir exists
    if [[ ! -d "$profile_dir" ]]; then
      szcdf_logging__warning "Settings profile must have a folder at \"$profile_dir\". Skipping"
      continue
    fi
    # Check if on_decide exists
    if [[ ! -f "$profile_dir/on_decide.sh" ]]; then
      szcdf_logging__warning "Settings profile is missing a discriminant at \"$profile_dir/on_decide.sh\". Skipping"
      continue
    fi
    # Extract the settings_profile name
    settings_profile=$(bash "$profile_dir/on_decide.sh")
    # Check if extracted properly
    if [[ $? -eq 0 && -n $settings_profile ]]; then
      # If extracted, break early
      szcdf_logging__info "Settings profile determined to be '$(tput smul)$settings_profile$(tput rmul)'."
      break
    fi
  done
  # If we reached the end of loop without extracting a profile name, use default
  if [[ -z $settings_profile ]]; then
    szcdf_logging__warning "No settings profiles found! Using settings profile '$(tput smul)default$(tput rmul)'."
    settings_profile='default'
  fi
  echo "$settings_profile"
}

# Detects and loads the profile
# $# = 0
szcdf_profile__detect_and_load() {
  # Detect the profile, setenv, then load from env
  local profile_name
  profile_name=$(szcdf_profile__detect)
  szcdf_profile__setenv "$profile_name"
  szcdf_profile__load "$profile_name"
}

# Gets the detected profile name
# $# = 0
# stdout = the detected profile name
szcdf_profile__get() {
  if [[ -z "$SZCDF_PROFILE_NAME" ]]; then
    local profile_name
    profile_name=$(szcdf_profile__detect)
    szcdf_profile__setenv "$profile_name"
  fi
  echo "$SZCDF_PROFILE_NAME"
}

# PRIVATE
# Sets the SZCDF_PROFILE_NAME environment variable
# $# = 1
# $1 = The profile name to set SZCDF_PROFILE_NAME
szcdf_profile__setenv() {
  export SZCDF_PROFILE_NAME=$1
}

szcdf_profile__load() {
  local profile_name=$1
  shift
  #TODO: Move checks and flag settings to somewhere else (modularize)
  # Check interactivity
  szcdf_shinter detect_and_set_is_interactive
  # Check if login-shell
  #TODO: Smarter bespoke checks for login-shell
  if [[ "$SZCDF_G__ENTRY_POINT" == *profile ]]; then
    export SZCDF_PROFILE__IS_LOGIN=1
  else
    export SZCDF_PROFILE__IS_LOGIN=
  fi
  # Check if profile dir exists
  local profile_dir="$SZCDF_G__ROOT_DIR/profile.d/$profile_name"
  if [[ ! -d "$profile_dir" ]]; then
    szcdf_logging__warning "Settings profile must have a folder at \"$profile_dir\". Skipping"
    return 1
  fi
  szcdf_logging__debug "Loading settings profile '$profile_name'..."
  # Run on_load if it exists, otherwise just skip this part
  if [[ ! -f "$profile_dir/on_load.sh" ]]; then
    szcdf_logging__debug "No on_load for settings profile '$profile_name'."
  else
    source "$profile_dir/on_load.sh"
  fi
  szcdf_logging__debug "Finished loading settings profile '$profile_name'."
}

# Displays usage
szcdf_profile__usage() {
  echo >&2 "Usage: szcdf_profile { detect | setenv | getenv | detect_and_load | load }"
}


######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_profile__cleanup() {
  unset -f szcdf_profile

  unset -f szcdf_profile__detect
  unset -f szcdf_profile__detect_and_load
  unset -f szcdf_profile__get
  unset -f szcdf_profile__setenv
  unset -f szcdf_profile__load
  unset -f szcdf_profile__usage

  unset -f szcdf_profile__cleanup
}
