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

szcdf_module_manager load colors
szcdf_module_manager load powerline

szcdf_logging__debug "Finished loading required modules for profile 'Nordlander__WSL'."

szcdf_logging__debug "Registering presets for profile 'Nordlander__WSL'..."

szcdf_preset register add-bash-recommended
szcdf_preset register set-shell-prompt-powerline-blue
# szcdf_preset register conda
# szcdf_preset register nodejs-dev
# szcdf_preset register szc-module-vim
szcdf_preset register zhaonetwork1-accessor

szcdf_logging__debug "Finished registering presets for profile 'Nordlander__WSL'."

szcdf_logging__debug "Adding other env variables..."
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
szcdf_logging__debug "Finished adding other env variables."

szcdf_logging__end_context
