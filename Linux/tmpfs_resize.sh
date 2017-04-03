#!/bin/bash

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
GREEN='\033[92m'
NOCOLOR='\033[0m'

SUCCESS="${GREEN}SUCCESS${NOCOLOR}: "
FAILURE="${RED}FAILURE${NOCOLOR}: "

function output {
	echo -e "${1}"
}

function output_error {
	output "${RED}ERROR${NOCOLOR}: ${1}"
}

function output_success {
	output "${GREEN}SUCCESS${NOCOLOR}: ${1}"
}

function tmpfs_resize {
	output "Resizing to ${YELLOW}${1}GB${NOCOLOR}."

	# if root else su
	if [ "$EUID" -ne 0 ]
	then
		su - root -c "mount -o remount,size=${1}G,noatime /tmp &>/dev/null"
	else
		mount -o remount,size=${1}G,noatime /tmp &>/dev/null
	fi	

	if [ ! $? -eq 0 ]
	then
		output_error "resizing to ${YELLOW}${1}GB${NOCOLOR} failed."
		exit 1
	else
		output_success "resizing to ${YELLOW}${1}GB${NOCOLOR} succeeded."
		df -h | grep "Use%"
		df -h | grep "/tmp"
		exit 0
	fi
}

# if no arguments
if [ $# -eq 0 ]
then
	output "Resizes tmpfs /tmp to chosen size in GB."
	output "Example:"
	output "  ${YELLOW}./tmpfs_resize 8${NOCOLOR}"

	exit 0
fi

# this rejects empty strings and strings containing non-digits,
# accepting everything else.
case $1 in
    '' | *[!0-9]* )
		output_error "not a number: ${YELLOW}${1}${NOCOLOR}"
		exit 1
		;;
    *)
		tmpfs_resize $1
		;;
esac
