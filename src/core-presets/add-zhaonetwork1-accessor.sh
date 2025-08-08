#!/bin/bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: add-zhaonetwork1-accessor
# Purpose: Adds the zhaonetwork1 SSH keys to the keychain.

szcdf_logging__begin_context 'core-presets/add-zhaonetwork1-accessor'

szcdf_logging__debug "Running add-zhaonetwork1-accessor..."

if [[ ! -e /usr/bin/keychain ]]; then
  szcdf_logging__warning "/usr/bin/keychain is missing, but required to store the zhaonetwork1 SSH keys. Skipping preset add-zhaonetwork1-accessor."
elif [[ ! -e "$HOME"/.ssh/id_rsa.zhaonetwork1 ]]; then
  szcdf_logging__warning "Expected RSA SSH key at '$HOME/.ssh/id_rsa.zhaonetwork1', but file is missing. Skipping preset add-zhaonetwork1-accessor." 
else
  /usr/bin/keychain "$HOME"/.ssh/id_rsa.zhaonetwork1
fi

if [[ ! -d $HOME/.keychain ]]; then
  szc_logging__warning "Directory $HOME/.keychain not found. Skipping keychain setup..."
  return
fi

if [[ ! -e $HOME/.keychain/$(hostname)-sh ]]; then
  szc_logging__warning "No keys found in keychain. Skipping keychain setup..."
  return
fi

source $HOME/.keychain/$(hostname)-sh

szcdf_logging__debug "Finished running add-zhaonetwork1-accessor."

szcdf_logging__end_context
