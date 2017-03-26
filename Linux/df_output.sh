#!/bin/bash

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
NOCOLOR='\033[0m'

VERBOSE=0
HUMAN=0
SI=0
FIELD=""
FIELD_LONG=""
TARGET=""

# if no arguments
if [ $# -eq 0 ]
then
	echo -e "Outputs chosen field from chosen target from df utility."
	echo -e "To easily use with the watch utility or in other scripts."
	echo -e "Options:"
	echo -e "  ${YELLOW}-o <arg>${NOCOLOR}    choose which field to output (REQUIRED)"
	echo -e "              Accepts: ${YELLOW}size${NOCOLOR}, ${YELLOW}used${NOCOLOR}, ${YELLOW}available${NOCOLOR}, or ${YELLOW}percent${NOCOLOR}"
	echo -e "  ${YELLOW}-t <arg>${NOCOLOR}    target device or mountpoint (REQUIRED)"
	echo -e "  ${YELLOW}-h${NOCOLOR}          print sizes in powers of 1024 (e.g., 1023M)"
	echo -e "  ${YELLOW}-H${NOCOLOR}          print sizes in powers of 1000 (e.g., 1.1G)"
	echo -e "  ${YELLOW}-v${NOCOLOR}          verbosity, not to be used in scripts that only want the one value"

	exit 0
fi

# parses options -o and -t with arguments
#   if an argument to these options is provided it will be placed in OPTARG
#   if no argument is provided getopts will set opt to : so we can catch
#   this as an error
# and options -H, -h, and -v without arguments
while getopts ":Hhvo:t:" opt
do
	case ${opt} in
		v )
			VERBOSE=1
			;;
		h )
			HUMAN=1
			;;
		H )
			SI=1
			;;
		o )
			FIELD=$OPTARG
			;;
		t )
			TARGET=$OPTARG
			;;
		: )
			echo -e "${RED}Error${NOCOLOR}: option ${YELLOW}${1}${NOCOLOR} requires arguments."
			exit 1
			;;
	esac
done

# remove options already handled from $@
shift $((OPTIND -1))

if [ $HUMAN -eq 1 ] && [ $SI -eq 1 ]
then
	echo -e "${RED}Error${NOCOLOR}: options ${YELLOW}-h${NOCOLOR} and ${YELLOW}-H${NOCOLOR} cannot be used at the same time."
	exit 1
fi

df | grep "${TARGET}" &>/dev/null

if [ $? -eq 1 ]
then
	echo -e "${RED}Error${NOCOLOR}: target ${YELLOW}${TARGET}${NOCOLOR} not found."
	exit 1
fi

case $FIELD in
	"size" )
		FIELD_LONG="Total"
		;;
	"used" )
		FIELD_LONG="Used"
		;;
	"available" )
		FIELD="avail"
		FIELD_LONG="Available"
		;;
	"percent" )
		FIELD="pcent"
		FIELD_LONG="Percentage used"
		;;
	"" )
		echo -e "${RED}Error${NOCOLOR}: no output field chosen."
		exit 1
		;;
	* )
		echo -e "${RED}Error${NOCOLOR}: invalid option field ${YELLOW}${FIELD}${NOCOLOR}."
		exit 1
		;;
esac

DO="df"

if [ $HUMAN -eq 1 ]
then
	DO="df -h"
elif [ $SI -eq 1 ]
then
	DO="df -H"
	echo -e "Did you know there are 1024 bytes in a kilobyte? ${RED}ACT LIKE IT ${NOCOLOR}"
fi

if [ $VERBOSE -eq 1 ]
then
	echo -e "${YELLOW}${FIELD_LONG}${NOCOLOR} space on ${YELLOW}${TARGET}${NOCOLOR}:"
fi

# awk removes the leading space
$DO --output=$FIELD $TARGET | sed -n '2p' | awk '{print $1}'

# probably shouldn't get here
if [ $? -eq 1 ]
then
	echo -e "${RED}Error${NOCOLOR}: Something went awfully wrong."
fi
