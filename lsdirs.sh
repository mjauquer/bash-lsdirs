#! /bin/sh

source ~/code/bash/lsdirs/getoptx.bash
source ~/code/bash/lsdirs/upvars.sh

#=======================================================================
#
#         FILE: lsdirs.sh
#
#        USAGE: See function usage below.
#
#  DESCRIPTION: Print a list (a subset) of directories which is a
#               combination of the set of directories listed in PATH...,
#               whose total size in bytes is less than the amount
#               specified in the max-size option and greater than
#               the size of any other combination that satisfies that
#               condition.
#
# REQUIREMENTS: upvars.sh, getoptx.sh
#         BUGS: --
#        NOTES: --
#       AUTHOR: Marcelo Auquer, auquer@gmail.com
#      CREATED: 03/13/2012
#     REVISION: 04/27/2012
#
#======================================================================= 

#===  FUNCTION =========================================================
#
#        NAME: usage
#
#       USAGE: usage
#
# DESCRIPTION: Print a help message to stdout.
#
#=======================================================================
usage () {
	cat <<- EOF
	Usage: lsdirs.sh --max-size KILOBYTES PATH... 
	
	Change the name of files and subdirectories of the directories
	listed in PATH...

	--max-size The maximum size to be observed.
	             Some useful sizes: 
	               4167680 (4020 Mb).
	EOF
}

#===  FUNCTION =========================================================
#
#        NAME: get_masks
#
#       USAGE: get_masks VARNAME LENGTH
#
# DESCRIPTION: Generate a spaced-separated list of all posible
#              combinations of ones and zeros of the specified length.
#              Store that list in the caller's variable VARNAME.
#
#  PARAMETERS: VARNAME: A variable name.
#              LENGTH:  The amount of numbers in each combination to be
#                       formed.
#
#=======================================================================
get_masks () {
	for (( i=0; i<$2; i++ ))
	do
		bracestr="${bracestr}{0..1}"
	done
	local masklist=$(sh -c "echo $bracestr")
	local masktot=$((2**${2}))
	local $1 && upvars -a$masktot $1 $masklist
}

#===  FUNCTION =========================================================
#
#        NAME: get_maxdirs
#
#       USAGE: get_maxdirs VARNAME MAXSIZE PATH...
#
# DESCRIPTION: Calculate the maximum amount of directories that can be
#              included in a subset without surpassing the maximum size
#              limit. Store that number in the caller's variable
#              VARNAME.
#
#  PARAMETERS: VARNAME: A variable name.
#              MAXSIZE: A size in bytes.
#              PATH...: A list of directories.
#
#=======================================================================
get_maxdirs () {
	local sortdu=$(du -s ${@:3} | sort -n | cut -f1)
	local acsize=0
	local numofdirs=0
	for size in $sortdu
	do
		while [ $acsize -lt $2 ]
		do
			acsize=$((acsize+size))
			numofdirs=$((numofdirs+1))
		done
	done
	local $1 && upvar $1 $numofdirs
}

#===  FUNCTION =========================================================
#
#        NAME: get_mindirs
#
#       USAGE: get_mindirs VARNAME MAXSIZE PATH...
#
# DESCRIPTION: Calculate the minimum amount of directories to be
#              included in a subset. Store that number in the caller's
#              variable VARNAME.
#
#  PARAMETERS: VARNAME: A variable name.
#              MAXSIZE: A size in bytes.
#              PATH...: A list of directories.
#
#=======================================================================
get_mindirs () {
	local sortdu=$(du -s ${@:3} | sort -nr | cut -f1)
	local acsize=0
	local numofdirs=0
	for size in $sortdu
	do
		while [ $acsize -le $2 ]
		do
			acsize=$((acsize+size))
			numofdirs=$((numofdirs+1))
		done
	done
	local $1 && upvar $1 $numofdirs
}

#===  FUNCTION =========================================================
#
#        NAME: is_validmask
#
#       USAGE: is_validmask MASK MIN MAX PATH...
#
# DESCRIPTION: Return 0 if MASK has a valid number of ones that allows
#              it to be used to select a valid number of directories of
#              PATH... to be included in a subset, without surpassing
#              the total size limit specified by MAXSIZE. Otherwise,
#              return 1.
#
#  PARAMETERS: MASK:    A string containing only ones and zeros.
#              MIN:     Minimum number of ones in a mask to be valid.
#              MAX:     Maximum number of ones in a mask to be valid.
#              PATH...: A list of directories.
#
#=======================================================================
is_validmask () {
	local ones=${1//[^1]}
	if [ \( ${#ones} -lt $2 \) -o \( ${#ones} -gt $3 \) ] 
	then
		return 1
	fi
	return 0
}

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Checking for a well-formatted command line.
#-----------------------------------------------------------------------

[[ $# -eq 0 ]] && usage && exit

#-----------------------------------------------------------------------
# Parse command line options.
#-----------------------------------------------------------------------

while getoptex "max-size:" "${@}"
do
	case "$OPTOPT" in
		max-size) maxsize="$OPTARG"
			  ;;
	esac
done
shift $(($OPTIND-1))

#-----------------------------------------------------------------------
# Filter directories larger than MAXSIZE.
#-----------------------------------------------------------------------

for arg
do
	duarr=( $(du -s $arg) )
	if [ ${duarr[0]} -lt $maxsize ]
	then
		sizarr[$ind]=${duarr[0]}
		dirarr[$ind]=${duarr[1]}
		ind=$((ind+1))
	fi
done

#-----------------------------------------------------------------------
# Select the best combination of directories.
#-----------------------------------------------------------------------

get_maxdirs maxdirs $maxsize ${dirarr[@]}
get_mindirs mindirs $maxsize ${dirarr[@]}
get_masks masks ${#dirarr[@]}
closersize=0
for mask in ${masks[@]}
do
	! is_validmask $mask $mindirs $maxdirs && continue
	size=0
	for ((i=0; i < ${#mask}; i++))
	do
		if [ ${mask:$i:1} == 1 ]
		then
			size=$(($size+${sizarr[$i]}))
		fi
	done
	if [ \( $size -gt $closersize \) -a \( $size -le $maxsize \) ]
	then
		closersize=$size
		bestmask=$mask
	fi
done

#-----------------------------------------------------------------------
# Print the results.
#-----------------------------------------------------------------------

for (( f=0; f < ${#bestmask}; f++ ))
do
	[[ ${bestmask:$f:1} == 1 ]] && echo ${dirarr[$f]}
done
echo "Total: $closersize"
