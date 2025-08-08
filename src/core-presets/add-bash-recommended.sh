#!/bin/bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: add-bash-recommended
# Purpose: Generally recommended settings for bash.

szcdf_logging__begin_context 'core-presets/add-bash-recommended'

szcdf_logging__debug "Running add-bash-recommended..."

if szcdf_shinter get_is_interactive; then

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Set the terminal to xterm if rxvt
case "$TERM" in
  rxvt-unicode-256color)
    export TERM=xterm-256color
    ;;
  rxvt-unicode-color)
    export TERM=xterm-color
    ;;
esac

# Set directory colors for ls listings
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

LS_COLORS=$LS_COLORS:'di=0;37:' ; export LS_COLORS

fi # szcdf_shinter get_is_interactive

# Below are things to do regardless of interactivity

if [[ -z "$LANG" ]]; then
  szcdf_logging__warning "No LANG set. Defaulting to 'en_US.UTF-8'..."
  export LANG=en_US.UTF-8
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Set default editor -- always vim <3
export EDITOR=vim

# Source the shell aliases
if [[ -f "$HOME/.aliases" ]]; then
  source "$HOME/.aliases"
fi

if [[ -f "$HOME/.bash_aliases" ]]; then
  source "$HOME/.bash_aliases"
fi

szcdf_logging__debug "Finished running add-bash-recommended."

szcdf_logging__end_context
