#!/usr/bin/env bash
###############################################################################
#
# szcdfi.sh
# Stephen Zhao

######### CONSTANTS ###########################################################

# Internal error codes
ERROR_FATAL=1

# Internal return codes
RC_SPEC_DIRECTIVE_UNKNOWN=64
RC_SPEC_DIRECTIVE_EMPTY=65
RC_SPEC_DIRECTIVE_COMMENT=66


######### MAIN ################################################################

szcdf_install__main() {
  SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

  # Parse user-entered args
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      -i|--package-dir)
        if [[ $# -gt 0 ]]; then
          PKG_DIR="$1"
          shift
        else
          szcdf_install__usage
          return $ERROR_FATAL
        fi
        ;;
      -s|--spec)
        if [[ $# -gt 0 ]]; then
          INSTALL_SPEC_FILE="$1"
          shift
        else
          szcdf_install__usage
          return $ERROR_FATAL
        fi
        ;;
      -h|--help)
        szcdf_install__usage
        return
        ;;
      -I|--non-interactive)
        IS_INTERACTIVE=0
        ;;
      -i|--interactive)
        IS_INTERACTIVE=1
        ;;
      -m|--mode)
        if [[ $# -gt 0 ]]; then
          INSTALL_MODE="$1"
          shift
        else
          szcdf_install__usage
          return $ERROR_FATAL
        fi
        ;;
      *)
        echo >&2 "Invalid argument: $arg"
        echo >&2 ""
        szcdf_install__usage
        return $ERROR_FATAL
        ;;
    esac
  done

  # Consolidate with default args

  # If spec file was provided, but the package dir was not,
  # then use the spec file to deduce a likely package dir
  if [[ -z "$PKG_DIR" ]] && [[ -n "$INSTALL_SPEC_FILE" ]]; then

    if [[ ! -f "$INSTALL_SPEC_FILE" ]]; then
      return $ERROR_FATAL
    fi

    PKG_DIR="$(dirname "$(dirname "$INSTALL_SPEC_FILE")")"

  # If package dir was provided, but the spec file was not,
  # then use the package dir to deduce a likely spec file
  elif [[ -n "$PKG_DIR" ]] && [[ -z "$INSTALL_SPEC_FILE" ]]; then
    INSTALL_SPEC_FILE="$PKG_DIR/.szcdf/szcdf_package.szcdfis"
    
    if [[ ! -f "$INSTALL_SPEC_FILE" ]]; then
      return $ERROR_FATAL
    fi

  # If neither are provided, use defaults
  elif [[ -z "$PKG_DIR" ]] && [[ -z "$INSTALL_SPEC_FILE" ]]; then
    PKG_DIR="$(pwd)"
    INSTALL_SPEC_FILE="$(szcdf_install__get_default_spec_file_from_pkg_dir $PKG_DIR)"

    # Check ancestor dirs until we find a valid package directory
    while [[ ! -f "$INSTALL_SPEC_FILE" ]]; do
      local new_pkg_dir="$(dirname $PKG_DIR)"
      # If parent of current dir is unavailable, we went all the way to the root dir
      # so no package dir can be found
      if [[ "$new_pkg_dir" == "$PKG_DIR" ]]; then
        return $ERROR_FATAL
      fi
      PKG_DIR="$new_pkg_dir"
      INSTALL_SPEC_FILE="$(szcdf_install__get_default_spec_file_from_pkg_dir $PKG_DIR)"
    done

  # Otherwise, use the user-inputted values
  fi

  # Display intro

  szcdf_install__display_intro

  # If install mode is not specified, prompt user
  if [[ -z "$INSTALL_MODE" ]]; then
    szcdf_install__prompt_install_mode INSTALL_MODE
  
  # Otherwise, use the user-inputted values
  fi

  # Execute

  # Execute corresponding install mode
  case $INSTALL_MODE in
    1|quick)
      szcdf_install__quick_install
      ;;
    2|custom)
      szcdf_install__custom_install
      ;;
  esac
}

szcdf_install__get_default_spec_file_from_pkg_dir() {
  echo "$1/.szcdf/szcdf_package.szcdfis"
}


######### HELP ################################################################

szcdf_install__usage() {
  cat >&2 "$SCRIPT_DIR/../docs/usage.txt"
}


######### INSTALL MODES RUNNERS ###############################################

szcdf_install__quick_install() {
  echo "The installer will make the following changes:"
  echo ""

  local preview
  local preview_rc
  local execution_rc
  local instatus
  while instatus= read -r -u 3 line
  do
    preview="$(szcdf_install__preview_spec_command $line)"
    preview_rc=$?
    if [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_EMPTY ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_COMMENT ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_UNKNOWN ]]; then
      continue
    elif [[ $preview_rc -ne 0 ]]; then
      echo "An error was encountered when previewing install spec file: $preview_rc"
      return $ERROR_FATAL
    fi
    echo $preview
  done 3<"$INSTALL_SPEC_FILE"
  unset instatus

  echo ""

  if ! szcdf_install__prompt_confirmation_is_yes "Continue with the install?"; then
    echo "Aborting install...."
    return 1
  fi

  echo ""
  echo "Installing..."

  local instatus
  while instatus= read -r -u 3 line
  do
    szcdf_install__execute_spec_command "$line"
    execution_rc=$?
    if [[ $execution_rc -ne 0 ]]; then
      echo "An error was encountered when executing install spec file: $execution_rc"
      return $ERROR_FATAL
    fi
  done 3<"$INSTALL_SPEC_FILE"
  unset instatus

  echo ""
  echo "Installation was successful!"
}

szcdf_install__custom_install() {
  echo ""
  echo "Installing..."

  local preview
  local preview_rc
  local execution_rc
  local instatus
  local step_counter=1
  while instatus= read -r -u 3 line
  do
    preview="$(szcdf_install__preview_spec_command $line)"
    preview_rc=$?
    if [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_EMPTY ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_COMMENT ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_UNKNOWN ]]; then
      continue
    elif [[ $preview_rc -ne 0 ]]; then
      echo "An error was encountered when previewing install spec file: $preview_rc"
      return $ERROR_FATAL
    fi
    echo ""
    echo "[Step $step_counter]"
    echo $preview
    if ! szcdf_install__prompt_confirmation_is_yes "Run?"; then
      echo "Skipping..."
      step_counter=$(($step_counter + 1))
      continue
    fi
    echo "Processing..."
    szcdf_install__execute_spec_command "$line"
    execution_rc=$?
    if [[ $execution_rc -ne 0 ]]; then
      echo "An error was encountered when executing install spec file: $execution_rc"
      return $ERROR_FATAL
    fi
    step_counter=$(($step_counter + 1))
  done 3< "$INSTALL_SPEC_FILE"
  unset instatus

  echo ""
  echo "Installation was successful!"
}


######### PROMPTS #############################################################

szcdf_install__prompt_install_mode() {
  local prompt_text="Choose an option [1 or 2]:"
  echo -en "$prompt_text "
  read install_mode
  local isLoop=true
  while $isLoop; do
    case $install_mode in
      1|2)
        isLoop=false
        ;;
      *)
        echo "Invalid input"
        echo -en "$prompt_text "
        read install_mode
        ;;
    esac
  done
  declare -g "$1=$install_mode"
}

szcdf_install__prompt_confirmation_is_yes() {
  local prompt_text=$1
  echo -en "$prompt_text [$(tput setaf 2)Y$(tput sgr0)/$(tput setaf 1)n$(tput sgr0)]: "
  read user_confirm
  local isLoop=true
  while $isLoop; do
    case $user_confirm in
      [yY]|[yY][eE][sS])
        ret=0
        isLoop=false
        ;;
      [nN]|[nN][oO])
        ret=1
        isLoop=false
        ;;
      *)
        echo "Invalid input"
        echo -en "$prompt_text [$(tput setaf 2)Y$(tput sgr0)/$(tput setaf 1)n$(tput sgr0)]: "
        read user_confirm
        ;;
    esac
  done
  return $ret
}


######### PREVIEW #############################################################

szcdf_install__preview_spec_command() {
  # local line="$(echo "$1" | sed 's/\\r$//g')"
  # local directive="$(echo "$line" | awk '{print $1;}')"
  local directive=$1
  shift
  case $directive in
    COPY)
      szcdf_install__preview_copy $@
      ;;
    # GITCLONE)
    #   git_repo="$(echo "$line" | awk '{print $2;}')"
    #   clone_target="$(echo "$line" | awk '{print $3;}')"
    #   szcdf_install__display_output "Clone git repo: $git_repo -> CONFIG_ROOT:/$clone_target"
    #   return 0
    #   ;;
    # vimcmd)
    #   vim_cmds="$(echo "$line" | awk '{$1=""; print $0;}')"
    #   vim_cmds="$(echo "$line" | awk '{$1=""; print $0;}' | sed -E 's/([^[:space:]]+)/+\1/g')"
    #   szcdf_install__display_output "Run commands in vim: $vim_cmds"
    #   return 0
    #   ;;
    # shell)
    #   shell_cmd="$(echo "$line" | awk '{$1=""; print $0;}')"
    #   szcdf_install__display_output "Run shell command: $shell_cmd"
    #   return 0
    #   ;;
    EXTENDHEAD)
      ;;
    EXTENDTAIL)
      ;;
    \#*)
      return $RC_SPEC_DIRECTIVE_COMMENT
      ;;
    "")
      return $RC_SPEC_DIRECTIVE_EMPTY
      ;;
    *)
      szcdf_install__display_warning "Unknown directive \"$directive\" will be ignored"
      return $RC_SPEC_DIRECTIVE_UNKNOWN
      ;;
  esac
}

szcdf_install__preview_copy() {
  local source_
  local dest_
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      *) # Positional
        if [[ -z "$source_" ]]; then
          source_=$arg
        elif [[ -z "$dest_" ]]; then
          dest_=$arg
        fi
        ;;
    esac
  done
  szcdf_install__display_output "Copy file(s): $PKG_DIR/$source_ -> $dest_"
}


######### EXECUTOR ############################################################

szcdf_install__execute_spec_command() {
  :
  # local line="$(echo "$1" | sed 's/\\r$//g')"
  # local directive="$(echo "$line" | awk '{print $1;}')" 
  # case $directive in
  #   softln)
  #     target="$(echo "$line" | awk '{print $2;}')"
  #     link="$(echo "$line" | awk '{print $3;}')"
  #     hostname_override="$(echo "$line" | awk '{print $4;}')" # optional
  #     # Check if file for hostname_override exists
  #     if [[ -z "$hostname_override" ]] && [[ -e "$ROOT_DIR/$target.$HOSTNAME" ]]; then
  #       # Doesn't exist, so check if default hostname exists
  #       # If it exists, set target to that
  #       target="$target.$HOSTNAME"
  #     elif [[ -e "$ROOT_DIR/$target.$hostname_override" ]]; then
  #       # hostname_override file exists, so set target to that
  #       target="$target.$hostname_override"
  #     fi
  #     # Check if file already exists
  #     if [[ -e "$HOME/$link" ]]; then
  #       old_target="$(readlink -f "$HOME/$link")"
  #       # Check old target is the same as new target
  #       if [[ "$old_target" == "$ROOT_DIR/$target" ]]; then
  #         # If they are equal, skip
  #         szcdf_install__display_output "Softlink '$HOME/$link' exists"
  #         szcdf_install__display_output_append "and correctly points to '$ROOT_DIR/$target'."
  #         szcdf_install__display_output_append "Skipping..."
  #         return
  #       fi
  #       # Check with the user if he/she wants to replace it
  #       local prompt_text=$(echo -en \
  #         $(szcdf_install__display_output "The installer wants to replace the file $HOME/$link:")"\n"\
  #         $(szcdf_install__display_output_append "Old target: $(tput setaf 1)$old_target$(tput sgr0)")"\n"\
  #         $(szcdf_install__display_output_append "New target: $(tput setaf 2)$ROOT_DIR/$target$(tput sgr0)")"\n"\
  #         $(szcdf_install__display_output_append "Replace?")\
  #       )
  #       if ! szc_i_install__prompt_confirmation "$prompt_text"; then
  #         szcdf_install__display_warning "$HOME/$link will not be created."
  #         return
  #       fi
  #       # Remove the old link
  #       rm "$HOME/$link"
  #     fi
  #     # Check to see if folder exists, otherwise make a folder
  #     if [[ ! -e "$(dirname "$HOME/$link")" ]]; then
  #       mkdir -p "$(dirname "$HOME/$link")"
  #     fi
  #     # Create the link
  #     ln -vs "$ROOT_DIR/$target" "$HOME/$link"
  #     ;;
  #   gitclone)
  #     git_repo="$(echo "$line" | awk '{print $2;}')"
  #     clone_target="$(echo "$line" | awk '{print $3;}')"
  #     git clone $git_repo $ROOT_DIR/$clone_target
  #     ;;
  #   vimcmd)
  #     vim_cmds="$(echo "$line" | awk '{$1=""; print $0;}' | sed -E 's/([^[:space:]]+)/+\1/g')"
  #     echo "Starting vim..."
  #     vim $vim_cmds - < /dev/null
  #     echo "Exited vim."
  #     ;;
  #   shell)
  #     shell_cmd="$(echo "$line" | awk '{$1=""; print $0;}')"
  #     #$shell_cmd
  #     szcdf_install__display_warning "Due to security reasons, running shell commands has been disabled"
  #     ;;
  #   \;*)
  #     ;;
  #   "")
  #     ;;
  #   \r)
  #     ;;
  #   *)
  #     szcdf_install__display_warning "Unknown directive \"$line\""
  #     ;;
  # esac
}


######### DISPLAY #############################################################

szcdf_install__display_intro() {
  echo ""
  echo "=== Stephen's dotfiles ==="
  echo ""
  echo "This installer will set up your environment to"
  echo "work with the dotfiles in this repository."
  echo ""
  echo "The installation may attempt to override some"
  echo "existing files."
  echo ""
  echo "The installer specification file being used:"
  echo "$INSTALL_SPEC_FILE"
  echo ""
  echo "There are two modes of installation:"
  echo "[1] Quick Install  - Preview all changes and install"
  echo "                     with one click. Conflicts will"
  echo "                     display prompts."
  echo "[2] Custom Install - Preview and install each change"
  echo "                     with a prompt."
  echo ""
}

szcdf_install__display_output() {
  echo "$@"
}

szcdf_install__display_output_append() {
  echo "    $@"
}

szcdf_install__display_warning() {
  echo "$(tput setaf 3)$@$(tput sgr0)"
}


######### RUN #################################################################

szcdf_install__main $@