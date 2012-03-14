#! /bin/sh

source ~/code/bash/getoptx/getoptx.bash
source ~/code/bash/upvars/upvars.sh

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
	Usage: chpathn.sh [OPTIONS] PATH...
	
	Change the name of files and subdirectories of the directories
	listed in PATH...

	--ascii-vowels Replace non-ascii vowels with ascii ones.
	 -h
	EOF
}

#===  FUNCTION =========================================================
#
#        NAME: asciivowels
#
#       USAGE: asciivowels PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Replace in the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every character of a non-ascii vowel with his matching
#              ascii vowel character. Store the resulting string in the
#              caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

while getoptex "max-size:" "${@}"
do
	case "$OPTOPT" in
		max-size) maxsize="$OPTARG"
			  ;;
	esac
done
shift $(($OPTIND-1))
dus=$(du -s ${@} | sort -n | cut -f1)
sizeac=0
counter=0 # Máxima cantidad de elementos sin superar maxsize
for size in $dus
do
	sizeac=$((sizeac+size))
	counter=$((counter+1))
	[[ $sizeac -gt $maxsize ]] && break
done
currsize=0
currcount=
size=0
duarr=
array=(${@})
for arg
do
	countstr="${countstr}{0..1}"
done
for count in $(sh -c "echo $countstr")
do
	ones="${count//[^1]}"
	[[ ${#ones} -gt $counter ]] && continue
	for ((i=0; i < ${#count}; i++))
	do
		if [ ${count:$i:1} == 1 ]
		then
			duarr=( $(du -s ${array[$i]}) )
			size=$(($size+${duarr[0]}))
		fi
	done
	[[ ($size -gt $currsize) && ($size -lt $maxsize) ]] && \
		currsize=$size && currcount=$count
	size=0
	duarr=
done
for ((f=0; f < ${#currcount}; f++))
do
	if [ ${currcount:$f:1} == 1 ]
	then
		echo ${array[$f]}
	fi
done
echo "Total: $currsize"
