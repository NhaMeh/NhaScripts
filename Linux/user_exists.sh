#!/bin/bash

# checks if a username exists
# arguments: username (required), verbosity (optional)
# example:
#    user_exists.sh root -v		// checks for user root, enables verbosity
#    user_exists.sh root v=0	// checks for user root, disables verbosity
#    user_exists.sh root		// checks for user root, default verbosity

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
GREEN='\033[92m'
NOCOLOR='\033[0m'

ARGS=$@
ID_BINARY="/usr/bin/id"
VERBOSE=0
USER=""

SUCCESS="${GREEN}SUCCESS${NOCOLOR}: "
FAILURE="${RED}FAILURE${NOCOLOR}: "

# check if $1 string length is 0
if [ -z $1 ]
then
	echo -e "${FAILURE}Not enough arguments."
	exit 2
else
	USER="$1"
	USER_Y="${YELLOW}${USER}${NOCOLOR}"

	# check for second argument
	if [ -n $2 ]
	then
		case $2 in
			"v=0")
				VERBOSE=0;;
			"v=1"|"-v")
				VERBOSE=1;;
			*)
				# invalid argument so let's ignore it
				;;
		esac
	fi

	# check if username exists
	if $ID_BINARY -u $USER > /dev/null 2>&1;
	then
		if [ $VERBOSE -eq 1 ]
		then
			echo -e "${SUCCESS}User ${USER_Y} exists!"
		fi
		exit 1
	else
		if [ $VERBOSE -eq 1 ]
		then
			echo -e "${FAILURE}User ${USER_Y} does NOT exist!"
		fi
		exit 0
	fi
fi