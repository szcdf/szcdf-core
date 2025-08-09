#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: default
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Profile
# Purpose: The default profile for szcdf-core.

szcdf_logging__begin_context 'core-profiles/default'

szcdf_logging__debug "Registering presets for profile 'default'..."

szcdf_preset register add-bash-recommended
szcdf_preset register set-shell-prompt-standard

szcdf_logging__debug "Finished registering presets for profile 'default'."

szcdf_logging__end_context
