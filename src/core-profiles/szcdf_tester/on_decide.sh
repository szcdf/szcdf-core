#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Profile: szcdf_tester
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Profile
# Purpose: Decides if the szcdf_tester profile should be used.

if [[ "$(hostname)" == "szcdf-tester" ]]; then
  echo 'szcdf_tester'
fi
