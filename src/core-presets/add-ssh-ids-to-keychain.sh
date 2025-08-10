#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-ssh-ids-to-keychain
# Purpose: Adds all SSH keys to the keychain.

szcdf_logging__begin_context 'core-presets/add-ssh-ids-to-keychain'

szcdf_logging__debug "Running add-ssh-ids-to-keychain..."

if [[ ! -e /usr/bin/keychain ]]; then
  szcdf_logging__warning "/usr/bin/keychain is missing, but required to store the SSH keys. Skipping preset add-ssh-ids-to-keychain."
else
  for key in "$HOME"/.ssh/id_*; do
    if [[ -e "$key" ]]; then
      /usr/bin/keychain "$key"
    fi
  done
fi

if [[ ! -d $HOME/.keychain ]]; then
  szcdf_logging__warning "Directory $HOME/.keychain not found. Skipping keychain setup..."
  return
fi

if [[ ! -e $HOME/.keychain/$(hostname)-sh ]]; then
  szcdf_logging__warning "No keys found in keychain. Skipping keychain setup..."
  return
fi

source $HOME/.keychain/$(hostname)-sh

szcdf_logging__debug "Finished running add-ssh-mail-zhaostephen-com."

szcdf_logging__end_context
