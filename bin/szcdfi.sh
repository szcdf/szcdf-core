#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Installer
# Purpose: The installer for szcdf package system.

######### CONSTANTS ###########################################################

# Internal error codes
ERROR_FATAL=1

# Internal return codes
RC_SPEC_DIRECTIVE_UNKNOWN=64
RC_SPEC_DIRECTIVE_EMPTY=65
RC_SPEC_DIRECTIVE_COMMENT=66
RC_SPEC_DIRECTIVE_BADARGS=67


######### MAIN ################################################################

szcdf_install__main() {
  # Determine directory of running script
  SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  
  # Determine directory of SZCDF configuration files
  local DOT_CONFIG_SZCDF_PATH="$HOME/.config/szcdf"
  local DOT_SZCDF_PATH="$HOME/.szcdf"
  if [[ -d "$DOT_CONFIG_SZCDF_PATH" ]]; then
    CONFIG_ROOT="$DOT_CONFIG_SZCDF_PATH"
  elif [[ -d "$DOT_SZCDF_PATH" ]]; then
    CONFIG_ROOT="$DOT_SZCDF_PATH"
  elif [[ -e "$DOT_CONFIG_SZCDF_PATH" ]] && [[ -e "$DOT_SZCDF_PATH" ]]; then
    szcdf_install__display_error "Error: SZCDF config directory $DOT_CONFIG_SZCDF_PATH exists and is not a directory!"
    return $ERROR_FATAL
  elif [[ -e "$DOT_CONFIG_SZCDF_PATH" ]]; then
    mkdir -p "$DOT_SZCDF_PATH"
    CONFIG_ROOT="$DOT_SZCDF_PATH"
  else
    mkdir -p "$DOT_CONFIG_SZCDF_PATH"
    CONFIG_ROOT="$DOT_CONFIG_SZCDF_PATH"
  fi

  # Parse user-entered args
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      -p|--package-dir)
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
      szcdf_install__usage
      return $ERROR_FATAL
    fi

    PKG_DIR="$(dirname "$(dirname "$INSTALL_SPEC_FILE")")"

  # If package dir was provided, but the spec file was not,
  # then use the package dir to deduce a likely spec file
  elif [[ -n "$PKG_DIR" ]] && [[ -z "$INSTALL_SPEC_FILE" ]]; then
    INSTALL_SPEC_FILE="$(szcdf_install__get_default_spec_file_from_pkg_dir "$PKG_DIR")"
    
    if [[ ! -f "$INSTALL_SPEC_FILE" ]]; then
      echo "Could not determine install spec file from package dir '$PKG_DIR'."
      szcdf_install__usage
      return $ERROR_FATAL
    fi

  # If neither are provided, use defaults
  elif [[ -z "$PKG_DIR" ]] && [[ -z "$INSTALL_SPEC_FILE" ]]; then
    PKG_DIR="$(dirname "$SCRIPT_DIR")"
    INSTALL_SPEC_FILE="$(szcdf_install__get_default_spec_file_from_pkg_dir "$PKG_DIR")"

    # Check ancestor dirs until we find a valid package directory
    while [[ ! -f "$INSTALL_SPEC_FILE" ]]; do
      local new_pkg_dir
      new_pkg_dir="$(dirname "$PKG_DIR")"
      # If parent of current dir is unavailable, we went all the way to the root dir
      # so no package dir can be found
      if [[ "$new_pkg_dir" == "$PKG_DIR" ]]; then
        echo "Could not determine package dir from install spec file '$INSTALL_SPEC_FILE'."
        szcdf_install__usage
        return $ERROR_FATAL
      fi
      PKG_DIR="$new_pkg_dir"
      INSTALL_SPEC_FILE="$(szcdf_install__get_default_spec_file_from_pkg_dir "$PKG_DIR")"
    done

  # Otherwise, use the user-inputted values
  fi

  # Use interactive if not specified
  if [[ -z "$IS_INTERACTIVE" ]]; then
    IS_INTERACTIVE=1
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
  local step_counter

  step_counter=1
  while instatus='' read -r -u 3 line
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
      echo "An error was encountered when previewing install spec file on step $step_counter: rc=$preview_rc"
      return $ERROR_FATAL
    fi
    echo "[Step $step_counter] $preview"
    step_counter=$((step_counter + 1))
  done 3<"$INSTALL_SPEC_FILE"
  unset instatus

  echo ""

  if ! szcdf_install__prompt_confirmation_is_yes "Continue with the install?"; then
    echo "Aborting install...."
    return 1
  fi

  echo ""
  echo "Installing..."

  step_counter=1
  while instatus='' read -r -u 3 line
  do
    szcdf_install__execute_spec_command $line
    execution_rc=$?
    if [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_EMPTY ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_COMMENT ]]; then
      continue
    elif [[ $preview_rc -eq $RC_SPEC_DIRECTIVE_UNKNOWN ]]; then
      continue
    elif [[ $execution_rc -ne 0 ]]; then
      echo "An error was encountered when executing install spec file on step $step_counter: rc=$execution_rc"
      return $ERROR_FATAL
    fi
    echo "[Step $step_counter] Processing..."
    step_counter=$((step_counter + 1))
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
  local step_counter=1
  while instatus='' read -r -u 3 line
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
      echo "An error was encountered when previewing install spec file on step $step_counter: rc=$preview_rc"
      return $ERROR_FATAL
    fi
    echo ""
    echo "[Step $step_counter]"
    echo "$preview"
    if ! szcdf_install__prompt_confirmation_is_yes "Run?"; then
      echo "Skipping"
      step_counter=$((step_counter + 1))
      continue
    fi
    echo "Processing..."
    szcdf_install__execute_spec_command $line
    execution_rc=$?
    if [[ $execution_rc -ne 0 ]]; then
      echo "An error was encountered when executing install spec file on step $step_counter: rc=$execution_rc"
      return $ERROR_FATAL
    fi
    step_counter=$((step_counter + 1))
  done 3< "$INSTALL_SPEC_FILE"
  unset instatus

  echo ""
  echo "Installation was successful!"
}


######### PROMPTS #############################################################

szcdf_install__prompt_install_mode() {
  local -n install_mode_var=$1
  local prompt_text="Choose an option [1 or 2]:"
  echo -en "$prompt_text "
  read -r install_mode
  while true; do
    case $install_mode in
      1|2)
        break
        ;;
      *)
        echo "Invalid input"
        echo -en "$prompt_text "
        read -r install_mode
        ;;
    esac
  done
  install_mode_var=$install_mode
}

szcdf_install__prompt_confirmation_is_yes() {
  local prompt_text=$1
  echo -en "$prompt_text [$(tput setaf 2)Y$(tput sgr0)/$(tput setaf 1)n$(tput sgr0)]: "
  read -r user_confirm
  while true; do
    case $user_confirm in
      [yY]|[yY][eE][sS])
        return 0
        ;;
      [nN]|[nN][oO])
        return 1
        ;;
      *)
        echo "Invalid input"
        echo -en "$prompt_text [$(tput setaf 2)Y$(tput sgr0)/$(tput setaf 1)n$(tput sgr0)]: "
        read -r user_confirm
        ;;
    esac
  done
}


######### PREVIEW #############################################################

szcdf_install__preview_spec_command() {
  local directive=$1
  shift
  case $directive in
    COPY)
      szcdf_install__preview_copy "$@"
      ;;
    PREPENDTEXT)
      szcdf_install__preview_prependtext "$@"
      ;;
    APPENDTEXT)
      szcdf_install__preview_appendtext "$@"
      ;;
    \#*)
      return $RC_SPEC_DIRECTIVE_COMMENT
      ;;
    "")
      return $RC_SPEC_DIRECTIVE_EMPTY
      ;;
    *)
      szcdf_install__display_warning "Unknown directive \"$directive\" will be ignored."
      return $RC_SPEC_DIRECTIVE_UNKNOWN
      ;;
  esac
}

szcdf_install__preview_copy() {
  # Parse args
  local source_
  local dest_
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        fi
        ;;
    esac
  done
  
  local badargs=0
  if [[ -z "$source_" ]]; then
    szcdf_install__display_warning "Required arg <source> missing for COPY directive."
    badargs=1
  fi
  if [[ -z "$dest_" ]]; then
    szcdf_install__display_warning "Required arg <dest> missing for COPY directive."
    badargs=1
  fi

  if [[ $badargs == 1 ]]; then
    return $RC_SPEC_DIRECTIVE_BADARGS
  fi

  szcdf_install__display_output "Copy file(s) from $PKG_DIR/$source_ to $dest_"
}

szcdf_install__preview_prependtext() {
  # Parse args
  local source_
  local dest_
  local section_id
  local comment_indicator
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        elif [[ -z "$section_id" ]]; then
          section_id=$arg # required
        elif [[ -z "$comment_indicator" ]]; then
          comment_indicator=$arg # optional
        fi
        ;;
    esac
  done

  local badargs=0
  if [[ -z "$source_" ]]; then
    szcdf_install__display_warning "Required arg <source> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$dest_" ]]; then
    szcdf_install__display_warning "Required arg <dest> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$section_id" ]]; then
    szcdf_install__display_warning "Required arg <section_id> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$comment_indicator" ]]; then
    comment_indicator='#' # Default to shell comment indicator
  fi

  if [[ $badargs = 1 ]]; then
    return $RC_SPEC_DIRECTIVE_BADARGS
  fi

  szcdf_install__display_output "Prepend text from $PKG_DIR/$source_ to $dest_ with ID=$section_id if section doesn't exist."
}

szcdf_install__preview_appendtext() {
  # Parse args
  local source_
  local dest_
  local section_id
  local comment_indicator
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        elif [[ -z "$section_id" ]]; then
          section_id=$arg # required
        elif [[ -z "$comment_indicator" ]]; then
          comment_indicator=$arg # optional
        fi
        ;;
    esac
  done

  local badargs=0
  if [[ -z "$source_" ]]; then
    szcdf_install__display_warning "Required arg <source> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$dest_" ]]; then
    szcdf_install__display_warning "Required arg <dest> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$section_id" ]]; then
    szcdf_install__display_warning "Required arg <section_id> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$comment_indicator" ]]; then
    comment_indicator='#' # Default to shell comment indicator
  fi

  if [[ $badargs == 1 ]]; then
    return $RC_SPEC_DIRECTIVE_BADARGS
  fi

  szcdf_install__display_output "Append text from $PKG_DIR/$source_ to $dest_ with ID=$section_id if section doesn't exist."
}

######### EXECUTOR ############################################################

szcdf_install__execute_spec_command() {
  local directive=$1
  shift
  case $directive in
    COPY)
      szcdf_install__execute_copy "$@"
      ;;
    PREPENDTEXT)
      szcdf_install__execute_prependtext "$@"
      ;;
    APPENDTEXT)
      szcdf_install__execute_appendtext "$@"
      ;;
    \#*)
      return $RC_SPEC_DIRECTIVE_COMMENT
      ;;
    "")
      return $RC_SPEC_DIRECTIVE_EMPTY
      ;;
    *)
      return $RC_SPEC_DIRECTIVE_UNKNOWN
      ;;
  esac
}

szcdf_install__execute_copy() {
  # Parse args
  local source_
  local dest_
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        fi
        ;;
    esac
  done

  # Substitute to resolve config root
  dest_=${dest_//\$CONFIG_ROOT/$CONFIG_ROOT}

  # Check if destination already exists
  if [[ -e "$dest_" ]]; then
    old_link_target="$(readlink -f "$dest_")"
    # Check old target is the same as new target
    if [[ "$old_link_target" == "$PKG_DIR/$source_" ]]; then
      # If they are equal, skip
      szcdf_install__display_output "Link '$dest_' exists and already points to '$PKG_DIR/$source_'. Skipping"
      return 0
    fi
    # Check with the user if they want to replace it
    local prompt_text
    prompt_text=$(echo -en \
      "$(szcdf_install__display_output "The installer wants to replace the file '$dest_':")""\n"\
      "$(szcdf_install__display_output_append "Old target: $(tput setaf 1)$old_link_target$(tput sgr0)")""\n"\
      "$(szcdf_install__display_output_append "New target: $(tput setaf 2)$PKG_DIR/$source_$(tput sgr0)")""\n"\
      "$(szcdf_install__display_output_append "Replace?")"\
    )
    if ! szcdf_install__prompt_confirmation_is_yes "$prompt_text"; then
      szcdf_install__display_warning "$dest_ will not be created."
      return
    fi
    # Finally, if pass all checks, then proceed
    # Remove the old link
    rm "$dest_"
  fi
  # Check to see if directory exists, otherwise make a directory
  if [[ ! -e "$(dirname "$dest_")" ]]; then
    mkdir -p "$(dirname "$dest_")"
  fi
  # Create the link
  ln -vs "$PKG_DIR/$source_" "$dest_"
}

szcdf_install__execute_prependtext() {
  # Parse args
  local source_
  local dest_
  local section_id
  local comment_indicator
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        elif [[ -z "$section_id" ]]; then
          section_id=$arg # required
        elif [[ -z "$comment_indicator" ]]; then
          comment_indicator=$arg # optional
        fi
        ;;
    esac
  done

  local badargs=0
  if [[ -z "$source_" ]]; then
    szcdf_install__display_warning "Required arg <source> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$dest_" ]]; then
    szcdf_install__display_warning "Required arg <dest> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$section_id" ]]; then
    szcdf_install__display_warning "Required arg <section_id> missing for PREPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$comment_indicator" ]]; then
    comment_indicator='#' # Default to shell comment indicator
  fi

  if [[ $badargs = 1 ]]; then
    return $RC_SPEC_DIRECTIVE_BADARGS
  fi

  # Substitute to resolve config root
  dest_=${dest_//\$CONFIG_ROOT/$CONFIG_ROOT}

  # Validate source exists
  if [[ ! -f "$PKG_DIR/$source_" ]]; then
    szcdf_install__display_error "Source file not found: $PKG_DIR/$source_"
    return $ERROR_FATAL
  fi

  # Ensure destination directory exists (may create file if missing)
  if [[ ! -d "$(dirname "$dest_")" ]]; then
    mkdir -p "$(dirname "$dest_")"
  fi

  local begin_marker
  local end_marker
  begin_marker="$comment_indicator >>>>>>> SZCDF_GENERATED_TEXT // BEGIN SECTION_ID=$section_id // DO NOT EDIT MANUALLY"
  end_marker="$comment_indicator <<<<<<< SZCDF_GENERATED_TEXT // END SECTION_ID=$section_id // DO NOT EDIT MANUALLY"

  # If destination exists and contains the section, replace its contents
  if [[ -f "$dest_" ]] \
    && grep -F -q -- "$begin_marker" "$dest_" \
    && grep -F -q -- "$end_marker" "$dest_"; then

    local tmp_file
    tmp_file="$(mktemp)"

    awk -v b="$begin_marker" -v e="$end_marker" -v src_file="$PKG_DIR/$source_" '
      BEGIN { in_section = 0 }
      $0 == b {
        print $0
        while ((getline line < src_file) > 0) {
          print line
        }
        close(src_file)
        in_section = 1
        next
      }
      in_section {
        if ($0 == e) {
          print $0
          in_section = 0
        }
        next
      }
      { print $0 }
    ' "$dest_" > "$tmp_file"

    mv "$tmp_file" "$dest_"

  else
    # Otherwise, prepend a new section to the top of the file
    local tmp_file
    tmp_file="$(mktemp)"

    {
      printf "%s\n" "$begin_marker"
      cat "$PKG_DIR/$source_"
      printf "%s\n" "$end_marker"
      if [[ -f "$dest_" ]]; then
        cat "$dest_"
      fi
    } > "$tmp_file"

    mv "$tmp_file" "$dest_"
  fi

  return 0
}

szcdf_install__execute_appendtext() {
  # Parse args
  local source_
  local dest_
  local section_id
  local comment_indicator
  while [[ $# -gt 0 ]]; do
    local arg=$1
    shift
    case "$arg" in
      # Positional
      *)
        if [[ -z "$source_" ]]; then
          source_=$arg # required
        elif [[ -z "$dest_" ]]; then
          dest_=$arg # required
        elif [[ -z "$section_id" ]]; then
          section_id=$arg # required
        elif [[ -z "$comment_indicator" ]]; then
          comment_indicator=$arg # optional
        fi
        ;;
    esac
  done

  local badargs=0
  if [[ -z "$source_" ]]; then
    szcdf_install__display_warning "Required arg <source> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$dest_" ]]; then
    szcdf_install__display_warning "Required arg <dest> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$section_id" ]]; then
    szcdf_install__display_warning "Required arg <section_id> missing for APPENDTEXT directive."
    badargs=1
  fi
  if [[ -z "$comment_indicator" ]]; then
    comment_indicator='#' # Default to shell comment indicator
  fi

  if [[ $badargs = 1 ]]; then
    return $RC_SPEC_DIRECTIVE_BADARGS
  fi

  # Substitute to resolve config root
  dest_=${dest_//\$CONFIG_ROOT/$CONFIG_ROOT}

  # Validate source exists
  if [[ ! -f "$PKG_DIR/$source_" ]]; then
    szcdf_install__display_error "Source file not found: $PKG_DIR/$source_"
    return $ERROR_FATAL
  fi

  # Ensure destination directory exists (may create file if missing)
  if [[ ! -d "$(dirname "$dest_")" ]]; then
    mkdir -p "$(dirname "$dest_")"
  fi

  local begin_marker
  local end_marker
  begin_marker="$comment_indicator >>>>>>> SZCDF_GENERATED_TEXT // BEGIN SECTION_ID=$section_id // DO NOT EDIT MANUALLY"
  end_marker="$comment_indicator <<<<<<< SZCDF_GENERATED_TEXT // END SECTION_ID=$section_id // DO NOT EDIT MANUALLY"

  # If destination exists and contains the section, replace its contents
  if [[ -f "$dest_" ]] \
    && grep -F -q -- "$begin_marker" "$dest_" \
    && grep -F -q -- "$end_marker" "$dest_"; then

    local tmp_file
    tmp_file="$(mktemp)"

    awk -v b="$begin_marker" -v e="$end_marker" -v src_file="$PKG_DIR/$source_" '
      BEGIN { in_section = 0 }
      $0 == b {
        print $0
        while ((getline line < src_file) > 0) {
          print line
        }
        close(src_file)
        in_section = 1
        next
      }
      in_section {
        if ($0 == e) {
          print $0
          in_section = 0
        }
        next
      }
      { print $0 }
    ' "$dest_" > "$tmp_file"

    mv "$tmp_file" "$dest_"

  else
    # Otherwise, append a new section to the end of the file
    local tmp_file
    tmp_file="$(mktemp)"

    if [[ -f "$dest_" ]]; then
      cat "$dest_" > "$tmp_file"
    fi

    {
      printf "%s\n" "$begin_marker"
      cat "$PKG_DIR/$source_"
      printf "%s\n" "$end_marker"
    } >> "$tmp_file"

    mv "$tmp_file" "$dest_"
  fi

  return 0
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
  echo "The SZCDF configuration directory:"
  echo "$CONFIG_ROOT"
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
  echo "    $*"
}

szcdf_install__display_warning() {
  echo "$(tput setaf 3)$*$(tput sgr0)"
}

szcdf_install__display_error() {
  echo "$(tput setaf 1)$*$(tput sgr0)"
}


######### RUN #################################################################

szcdf_install__main "$@"