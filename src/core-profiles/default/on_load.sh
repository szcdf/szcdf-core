#!/usr/bin/env bash
###############################################################################
#
# szcdf_profile
# default/on_load.sh
# Stephen Zhao

szcdf_logging__begin_context 'profile-default/on_load'

szcdf_logging__debug "Loading presets for profile 'default'..."

szcdf_preset register bash-recommended
szcdf_preset register prompt-standard

szcdf_logging__debug "Finished loading presets for profile 'default'."

szcdf_logging__end_context
