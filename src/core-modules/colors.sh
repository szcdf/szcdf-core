#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Script Type: Module
# Module: colors
# Purpose: Supplies colors data.
#
# To load this module, run
# ```bash
# szcdf_module_manager load colors
# ```

######### MAIN ################################################################

szcdf_colors() {
  szcdf_logging__begin_context "szcdf_colors"
  case $1 in
    define)
      szcdf_colors__define
      ;;
    undefine)
      szcdf_colors__undefine
      ;;
    *)
      szcdf_logging__warning "Invalid arguments: $*"
      ;;
  esac
  szcdf_logging__end_context
}


######### COLOR UTILS #########################################################

# Prints the *nix colour corresponding to the given RGB colour.
# $# = 3
# $1 = R, 0-5
# $2 = G, 0-5
# $3 = B, 0-5
# stdout = *nix colour
szcdf_colors__rgb() {
  echo $((16 + $1 * 36 + $2 * 6 + $3))
}

# Prints the *nix colour corresponding to the given grayscale value.
# $# = 1
# $1 = grayscale, 0-100
# stdout = *nix colour
szcdf_colors__grayscale() {
  echo $(((2320 + 240 * $1 / 100 + 5)/10))
}


######### COLOR DEFS ##########################################################

szcdf_colors__init() {
  szcdf_logging__debug "Defining colors..."

  szcdfc_red=$(szcdf_colors__rgb 4 1 1)
  szcdfc_green=$(szcdf_colors__rgb 2 4 1)
  szcdfc_blue=$(szcdf_colors__rgb 1 2 5)
  
  szcdfc_darkgray=234
  szcdfc_gray20=$(szcdf_colors__grayscale 20)
  szcdfc_gray=$(szcdf_colors__grayscale 50)
  szcdfc_gray70=$(szcdf_colors__grayscale 70)

  szcdfc_blue_6=$(szcdf_colors__rgb 2 3 5)
  szcdfc_blue_5=$(szcdf_colors__rgb 1 2 4)

  szcdfc_red_6=$(szcdf_colors__rgb 5 2 2)
  szcdfc_red_5=$(szcdf_colors__rgb 4 1 1)

  szcdfc_gold_6=$(szcdf_colors__rgb 5 4 0)
  szcdfc_gold_5=$(szcdf_colors__rgb 4 3 0)

  szcdfc_pink_6=$(szcdf_colors__rgb 5 3 5)
  szcdfc_pink_5=$(szcdf_colors__rgb 4 2 4)

  szcdfc_violet_6=$(szcdf_colors__rgb 3 2 5)
  szcdfc_violet_5=$(szcdf_colors__rgb 2 1 4)

  szcdf_logging__debug "Finished defining colors."
}

szcdf_colors__undefine() {
  szcdf_logging__debug "Unsetting colors..."

  unset szcdfc_violet_5
  unset szcdfc_violet_6

  unset szcdfc_pink_5
  unset szcdfc_pink_6

  unset szcdfc_gold_5
  unset szcdfc_gold_6

  unset szcdfc_red_5
  unset szcdfc_red_6

  unset szcdfc_blue_5
  unset szcdfc_blue_6

  unset szcdfc_gray70
  unset szcdfc_gray
  unset szcdfc_gray20
  unset szcdfc_darkgray
  
  unset szcdfc_blue
  unset szcdfc_green
  unset szcdfc_red

  szcdf_logging__debug "Finished unsetting colors."
}


######### CLEANUP #############################################################

szcdf_colors__cleanup() {
  szcdf_colors__undefine

  unset -f szcdf_colors__init

  unset -f szcdf_colors__rgb
  unset -f szcdf_colors__grayscale

  unset -f szcdf_colors
  unset -f szcdf_colors__cleanup
}
