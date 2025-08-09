#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: startup
# Purpose: The entry point for the SZCDF system.
#
# To load this module, run
# ```bash
# szcdf_module_manager load startup
# ```

szcdf_startup() {
  szcdf_logging__begin_context "szcdf_startup"
  szcdf_logging__debug "Running szcdf_startup..."
  
  szcdf_logging__debug "Loading required modules..."
  szcdf_module_manager load shinter
  szcdf_module_manager load profile
  szcdf_module_manager load preset
  szcdf_logging__debug "Finished sourcing required modules."

  szcdf_logging__debug "Loading profile..."
  szcdf_profile detect_and_load
  szcdf_logging__debug "Finished loading profile."

  szcdf_logging__debug "Loading all registered presets..."
  szcdf_preset load_all_registered
  szcdf_logging__debug "Finished loading all registered presets."

  szcdf_logging__debug "Cleaning up..."
  szcdf_module_manager unload_all_loaded
  szcdf_logging__debug "Finished cleaning up."

  szcdf_logging__debug "Finished running szcdf_startup."
  szcdf_logging__end_context
}
