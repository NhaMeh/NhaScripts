#!/bin/bash

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
GREEN='\033[92m'
NOCOLOR='\033[0m'

DATE=$(date +%Y-%m-%d_%H%M%S)

GRUB_DIR="/boot/grub/"
GRUB_CONFIG_FILE="${GRUB_DIR}grub.cfg"
GRUB_CONFIG_FILE_NEW="${GRUB_CONFIG_FILE}.${DATE}"

# set to 0 to disable logging
LOGGING=1
LOG_DIR="/var/log/nha/"
LOG_FILE="${LOG_DIR}grub_config.log"

SUCCESS="${GREEN}SUCCESS${NOCOLOR}: "
FAILURE="${RED}FAILURE${NOCOLOR}: "
GRUB_CONFIG_FILE_Y="${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR}"
ABORTING="${RED}Aborting${NOCOLOR}."

function check_log_dir {
	if [ ! -d $LOG_DIR ]
	then 
        	# make the dir
	        mkdir -p $LOG_DIR
	fi
}

function check_log_file {
	if [ ! -f $LOG_FILE ]
	then
		# make the file
		touch $LOG_FILE
		# set appropriate permissions
		chmod 740 $LOG_FILE
	fi
}

function output {
	if [ $LOGGING -eq 1 ]
	then
		echo -e "$(date +"%Y-%m-%d %T") ${1}" >> $LOG_FILE
	fi

	echo -e "${1}"
}

function backup_grub_config_file {
	output "Backing up current ${GRUB_CONFIG_FILE_Y} to ${YELLOW}${GRUB_CONFIG_FILE_NEW}${NOCOLOR}"

	# just copying a file, moving on
	cp ${GRUB_CONFIG_FILE} ${GRUB_CONFIG_FILE_NEW}

	if [ $? -eq 0 ]
	then
		output "${SUCCESS}${GRUB_CONFIG_FILE_Y} has been successfully backed up."
	else
		output "${FAILURE}${GRUB_CONFIG_FILE_Y} could not be backed up. ${ABORTING}"
		exit
	fi

	# just adding some whitespace
	echo ""
	# list all the grub config files
	ls -lht $GRUB_CONFIG_FILE*
	# adding more whitespace
	echo ""
}

function generate_grub_config_file {
	output "Creating a new ${GRUB_CONFIG_FILE_Y}"

	# silently generate new grub config
	grub-mkconfig > ${GRUB_CONFIG_FILE} 2>/dev/null

	# check last command exit status to see if it failed or not
	if [ $? -eq 0 ]
	then
		output "${SUCCESS}${GRUB_CONFIG_FILE_Y} has been successfully generated."
	else
		output "${FAILURE}${GRUB_CONFIG_FILE_Y} could not be generated. ${ABORTING}"
		exit
	fi
}

check_log_dir
check_log_file

if [ -f $GRUB_CONFIG_FILE ]
then
	backup_grub_config_file
	generate_grub_config_file
else
	output "${FAILURE}${GRUB_CONFIG_FILE_Y} does not exist! ${ABORTING}"
	exit 1
fi
