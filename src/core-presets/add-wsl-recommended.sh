#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Preset
# Preset: add-wsl-recommended
# Purpose: Adds recommended settings for WSL.

szcdf_logging__debug "Adding recommended settings for WSL..."

szcdf_module_manager load bin_manager

# Add aliases for changing Windows drive letter
szcdf_bin_manager import change_win_drive.sh
alias C:='. change_win_drive.sh c'
alias c:='. change_win_drive.sh c'
alias D:='. change_win_drive.sh d'
alias d:='. change_win_drive.sh d'
alias E:='. change_win_drive.sh e'
alias e:='. change_win_drive.sh e'
alias F:='. change_win_drive.sh f'
alias f:='. change_win_drive.sh f'
alias G:='. change_win_drive.sh g'
alias g:='. change_win_drive.sh g'
alias H:='. change_win_drive.sh h'
alias h:='. change_win_drive.sh h'
alias I:='. change_win_drive.sh i'
alias i:='. change_win_drive.sh i'

# cd that works with windows paths
function cdw { cd "$(wslpath "$1")"; }

# open in vscode in windows
codew () (
  powershell.exe -Command "& code $@"
)

szcdf_logging__debug "Finished adding recommended settings for WSL."