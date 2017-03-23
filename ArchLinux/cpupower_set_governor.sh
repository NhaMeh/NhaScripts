#!/bin/bash
# sets the governor
# modern Intel (laptop) cpus only have "performance" and "powersave"

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
GREEN='\033[92m'
NOCOLOR='\033[0m'

SUCCESS="${GREEN}SUCCESS${NOCOLOR}: "
FAILURE="${RED}FAILURE${NOCOLOR}: "

DEFAULT="performance"
GOVERNOR="${DEFAULT}"

if [[ ! $# -eq 0 ]]
then
	case "$1" in
		# powersave
		[Pp][Oo][Ww][Ee][Rr][Ss][Aa][Vv][Ee] )
			GOVERNOR="powersave" ;;
		[Pp][Ee][Rr][Ff][Oo][Rr][Mm][Aa][Nn][Cc][Ee] )
			GOVERNOR="performance" ;;
		* )
			echo -e "${FAILURE}chosen governor not recognized. Choose between ${YELLOW}powersave${NOCOLOR} or ${YELLOW}performance${NOCOLOR}."
			exit ;;
	esac
fi

GOVERNOR_Y="${YELLOW}${GOVERNOR}${NOCOLOR}"

# if not root, su first
if [ "$EUID" -ne 0 ]
then
	su - root -c "cpupower -c all frequency-set -g $GOVERNOR &>/dev/null"
else
	cpupower -c all frequency-set -g $GOVERNOR &>/dev/null
fi

# check exit status
if [ $? -eq 0 ]
then
	echo -e "${SUCCESS}governor successfully set to ${GOVERNOR_Y}."
else
	echo -e "${FAILURE}governor could not be set to ${GOVERNOR_Y}."
fi
