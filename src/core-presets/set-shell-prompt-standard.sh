#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: set-shell-prompt-standard
# Purpose: Sets up the standard shell prompt.

szcdf_logging__begin_context 'core-presets/set-shell-prompt-standard'

if ! szcdf_shinter get_is_interactive; then

  szcdf_logging__info "Shell is not interactive. The set-shell-prompt-standard only applies when the shell is interative. Skipping..."

  szcdf_logging__debug "Finished setting up PS1."

  szcdf_logging__end_context

  return 0

fi

szcdf_logging__debug "Checking color support on terminal..."

# Determine if we want to use a color prompt
case "$TERM" in
  *-color|*-256color)
    color_prompt=yes
    ;;
esac

szcdf_logging__debug "Finished checking color support."

szcdf_logging__debug "Setting up PS1..."

if [ "$color_prompt" = yes ]; then
  szcdf_logging__debug "Using default PS1 color prompt."
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
  export PS1
else
  szcdf_logging__debug "Using default PS1 non-color prompt"
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
  export PS1
fi

szcdf_logging__debug "Finished setting up PS1."

unset color_prompt

szcdf_logging__end_context
