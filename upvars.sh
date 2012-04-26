#!/bin/bash
#=======================================================================
#
#         FILE: upvars.sh
#
#        USAGE: This file is meant to be sourced from others bash
#               scripts in order to call the functions defined here.
#
#  DESCRIPTION: The functions in this files are discused in the site:
#               http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
#
# REQUIREMENTS: --
#         BUGS: --
#        NOTES: See each function's description for further details.
#       AUTHOR: Both functions in here were published by Freddy Vulto,
#               fvul..@gmail.com (fill in the dots). 
#      CREATED: unknown.
#     REVISION: unknown.
#
#======================================================================= 

#===  FUNCTION =========================================================
#        NAME: upvar
# DESCRIPTION: Assign variable one scope above the caller.
#       USAGE: local VARNAME && upvar VARNAME VALUE [VALUE ...]
#  PARAMETERS: VARNAME (It's a parameter expansion of a posicional
#                       parameter which contains the name of the
#                       variable to assign value to).
#              VALUES  (Values to assign. If multiple values, an array
#                       is assigned, otherwise a single value is
#                       assigned.
#        NOTE: For assigning multiple variables, use 'upvars'. Do NOT
#              use multiple 'upvar' calls, since one 'upvar' call might
#              reassign a variable to be used by another 'upvar' call.
#=======================================================================
upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

#===  FUNCTION =========================================================
#        NAME: upvars
# DESCRIPTION: Assign variables one scope above the caller. Returns 1 if
#              errors ocurs.
#       USAGE: local VARNAME [VARNAME ...] &&
#              upvars [-v VARNAME VALUE] | [-aN VARNAME [VALUE ...]] ...
#  PARAMETERS: VARNAME (It's a parameter expansion of a posicional
#                       parameter which contains the name of the
#                       variable to assign value to).
#              VALUES  (Values to assign. If multiple values, an array
#                       is assigned, otherwise a single value is
#                       assigned.
#              -aN     (Assign next N values to VARNAME as an array).
#              -v      (Assign single value to VARNAME). 
#              --help  (Display this help and exit).
#              --version (Output version information and exit).
#   COPYRIGHT: Copyright (C) 2010 Freddy Vulto
#              License GPLv3+: GNU GPL version 3 or later 
#              <http://gnu.org/licenses/gpl.html>
#              This is free software: you are free to change and 
#              redistribute it. There is NO WARRANTY, to the extent
#              permitted by law."
#=======================================================================
upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            --help) echo "\
Usage: local varname [varname ...] &&
   ${FUNCNAME[0]} [-v varname value] | [-aN varname [value ...]] ...
Available OPTIONS:
-aN VARNAME [value ...]   assign next N values to varname as array
-v VARNAME value          assign single value to varname
--help                    display this help and exit
--version                 output version information and exit"
                return 0 ;;
            --version) echo "\
${FUNCNAME[0]}-0.9.dev
Copyright (C) 2010 Freddy Vulto
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
                return 0 ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}
