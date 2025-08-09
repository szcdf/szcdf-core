#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Managed User Script
# Purpose: Changes the Windows drive letter.

szcdf_logging__debug "Changing Windows drive letter..."

# Get the drive letter
local drive_letter=$1

cd /mnt/$drive_letter

szcdf_logging__debug "Finished changing Windows drive letter."