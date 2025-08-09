#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: Nordlander__WSL
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Profile
# Purpose: The Nordlander__WSL profile for szcdf-core.

szcdf_logging__begin_context 'core-profiles/Nordlander__WSL'

szcdf_logging__debug "Loading required modules for profile 'Nordlander__WSL'..."

szcdf_logging__debug "Finished loading required modules for profile 'Nordlander__WSL'."

szcdf_logging__debug "Registering presets for profile 'Nordlander__WSL'..."

szcdf_preset register add-bash-recommended
szcdf_preset register add-wsl-recommended
szcdf_preset register add-zhaonetwork1-accessor
szcdf_preset register add-vim-managed
szcdf_preset register add-conda-recommended
szcdf_preset register add-nodejs-dev
szcdf_preset register use-nord-theme
szcdf_preset register set-shell-prompt-powerline-blue

szcdf_logging__debug "Finished registering presets for profile 'Nordlander__WSL'."

szcdf_logging__debug "Adding other env variables..."

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

szcdf_logging__debug "Finished adding other env variables."

szcdf_logging__debug "Adding some common aliases..."

alias cdpr='cd /mnt/e/Projects/Dev'

szcdf_logging__debug "Finished adding some common aliases."

szcdf_logging__end_context
