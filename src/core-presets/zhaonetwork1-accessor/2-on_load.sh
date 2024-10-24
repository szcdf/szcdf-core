#!/bin/bash
###############################################################################
#
# szcdf_preset
# zhaonetwork1-accessor/2-on_run.sh
# Stephen Zhao

# The core script to run when the preset is run

szcdf_logging__begin_context 'preset-zhaonetwork1-accessor/on_run'

szcdf_logging__debug "Running on_run..."

if [[ ! -e /usr/bin/keychain ]]; then
  szcdf_logging__warning "/usr/bin/keychain is missing, but required to store the zhaonetwork1 SSH keys. Skipping preset zhaonetwork1-accessor."
elif [[ ! -e "$HOME"/.ssh/id_rsa.zhaonetwork1 ]]; then
  szcdf_logging__warning "Expected RSA SSH key at '$HOME/.ssh/id_rsa.zhaonetwork1', but file is missing. Skipping preset zhaonetwork1-accessor." 
else
  /usr/bin/keychain "$HOME"/.ssh/id_rsa.zhaonetwork1
fi

szcdf_logging__debug "Finished running on_run."

szcdf_logging__end_context
