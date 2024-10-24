#!/bin/bash
###############################################################################
#
# szcdf_preset
# prompt-standard/2-on_load.sh
# Stephen Zhao

# The core script to run when the preset is run

szcdf_logging__begin_context 'preset-prompt-standard/on_load'

if ! szcdf_shinter get_is_interactive; then

  szcdf_logging__info "Shell is not interactive. The on_load of preset-prompt-standard only applies when the shell is interative. Skipping..."

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
