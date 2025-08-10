#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Preset
# Preset: add-ssh-mail-zhaostephen-com
# Purpose: Adds the mail@zhaostephen.com SSH keys to the keychain.

szcdf_logging__begin_context 'core-presets/add-ssh-mail-zhaostephen-com'

szcdf_logging__debug "Running add-ssh-mail-zhaostephen-com..."

if [[ ! -e /usr/bin/keychain ]]; then
  szcdf_logging__warning "/usr/bin/keychain is missing, but required to store the mail@zhaostephen.com SSH keys. Skipping preset add-ssh-mail-zhaostephen-com."
elif [[ ! -e "$HOME"/.ssh/id_ed25519.mail-zhaostephen-com ]]; then
  szcdf_logging__warning "Expected ED25519 SSH key at '$HOME/.ssh/id_ed25519.mail-zhaostephen-com', but file is missing. Skipping preset add-ssh-mail-zhaostephen-com." 
else
  /usr/bin/keychain "$HOME"/.ssh/id_ed25519.mail-zhaostephen-com
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
