#!/usr/bin/env bash
###############################################################################
#
# Package: szcdf-core
# Author: Stephen Zhao (mail@zhaostephen.com)
# Type: Module
# Module: powerline
# Purpose: Helps with powerline customization.
#
# To load this module, run
# ```bash
# szcdf_module_manager load powerline
# ```

######### MAIN ################################################################

szcdf_powerline() {
  szcdf_logging__begin_context 'szcdf_powerline'

  local subcommand=$1
  shift

  case $subcommand in
    set_ps1_by_color_scheme)
      szcdf_powerline__set_ps1_by_color_scheme "$@"
      ;;
    *)
      szcdf_logging__warning "Invalid args: $*"
      ;;
  esac

  szcdf_logging__end_context
}


######### SUBCOMMANDS #########################################################

# $# = 1
# $1 = Color Theme Name
#   | RED | BLUE | GREEN | GOLD | PURPLE | PINK
# stdout = a PS1 prompt
szcdf_powerline__set_ps1_by_color_scheme() {
  local color_scheme_name=$1
  shift

  local c1
  local c2
  local c3
  case $color_scheme_name in
    RED)
      c1=$szcdfc_red_6
      c2=$szcdfc_red_5
      c3=$szcdfc_gray20
      ;;
    BLUE)
      c1=$szcdfc_blue_6
      c2=$szcdfc_blue_5
      c3=$szcdfc_gray20
      ;;
    GREEN)
      c1=$szcdfc_green_6
      c2=$szcdfc_green_5
      c3=$szcdfc_gray20
      ;;
    GOLD)
      c1=$szcdfc_gold_6
      c2=$szcdfc_gold_5
      c3=$szcdfc_gray20
      ;;
    PURPLE)
      c1=$szcdfc_violet_6
      c2=$szcdfc_violet_5
      c3=$szcdfc_gray20
      ;;
    PINK)
      c1=$szcdfc_pink_6
      c2=$szcdfc_pink_5
      c3=$szcdfc_gray20
      ;;
    *)
      szcdf_logging__warning "unknown color scheme: $color_scheme_name"
      return
      ;;
  esac

  # local segment1=$'\n\e[1;38;5;'$szcdfc_darkgray$';48;5;'$c1$'m \A \e[1;38;5;'$c1$';48;5;'$c2$'m\ue0b0'
  # local segment2=$'\e[1;38;5;'$szcdfc_darkgray$';48;5;'$c2$'m \u@\h \e[1;38;5;'$c2$';48;5;'$c3$'m\ue0b0'
  # local segment3=$'\e[1;38;5;'$szcdfc_gray70$';48;5;'$c3$'m \w \e[1;38;5;'$c3$';48;5;0m\ue0b0'
  # local segment4=$'\e[m\n \u2517\u2501\u25cf \$ '
  
  local segment1='\n\e[1;38;5;'$szcdfc_darkgray';48;5;'$c1'm \A \e[1;38;5;'$c1';48;5;'$c2'm'$'\ue0b0'
  local segment2='\e[1;38;5;'$szcdfc_darkgray';48;5;'$c2'm \u@\h \e[1;38;5;'$c2';48;5;'$c3'm'$'\ue0b0'
  local segment3='\e[1;38;5;'$szcdfc_gray70';48;5;'$c3'm \w \e[1;38;5;'$c3';48;5;0m'$'\ue0b0'
  local segment4='\e[m\n '$'\u2517\u2501\u25cf'' \$ '

  export PS1=$segment1$segment2$segment3$segment4
}


######### CLEANUP #############################################################

# Cleans up all of the functions
szcdf_powerline__cleanup() {
  unset -f szcdf_powerline

  unset -f szcdf_powerline__get_ps1_by_color_scheme

  unset -f szcdf_powerline__cleanup
}
