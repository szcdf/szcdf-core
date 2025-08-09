#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Managed User Script
# Purpose: Changes the Windows drive letter.

szcdf_logging__debug "Changing Windows drive letter..."

# Get the drive letter
cd /mnt/$1

szcdf_logging__debug "Finished changing Windows drive letter."