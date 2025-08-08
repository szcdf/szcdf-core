#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: szcdf_tester
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Profile
# Purpose: The szcdf_tester profile for szcdf-core.

szcdf_logging__begin_context 'core-profiles/szcdf_tester'

szcdf_logging__debug "Loading required modules..."

szcdf_module_manager load bin_manager

szcdf_logging__debug "Finished loading required modules."

szcdf_logging__debug "Registering presets for profile 'szcdf_tester'..."

szcdf_preset register add-bash-recommended
szcdf_preset register set-shell-prompt-powerline-blue
szcdf_preset register use-nord-theme

szcdf_logging__debug "Finished registering presets for profile 'szcdf_tester'."

szcdf_logging__debug "Including some scripts..."

szcdf_bin_manager import hello_world.sh

szcdf_logging__debug "Finished including some scripts."

szcdf_logging__end_context
