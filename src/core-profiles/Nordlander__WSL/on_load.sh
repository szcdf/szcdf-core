#!/usr/bin/env bash
###############################################################################
#
# szcdf_profile
# Nordlander__WSL/on_load.sh
# Stephen Zhao

szcdf_logging__begin_context 'profile-Nordlander__WSL/on_load'

szcdf_logging__debug "Loading required modules for profile 'Nordlander__WSL'..."

szcdf_module_manager load colors
szcdf_module_manager load powerline

szcdf_logging__debug "Finished loading required modules for profile 'Nordlander__WSL'."

szcdf_logging__debug "Loading presets for profile 'Nordlander__WSL'..."

szcdf_preset register bash-recommended
szcdf_preset register prompt-powerline-blue
# szcdf_preset register conda
# szcdf_preset register nodejs-dev
# szcdf_preset register szc-module-vim
szcdf_preset register zhaonetwork1-accessor

szcdf_logging__debug "Finished loading presets for profile 'Nordlander__WSL'."

szcdf_logging__debug "Adding other env variables..."
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
szcdf_logging__debug "Finished adding other env variables."

szcdf_logging__end_context
