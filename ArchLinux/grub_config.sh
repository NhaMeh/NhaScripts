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

LOGGING=1
LOG_DIR="/var/log/nha/"
LOG_FILE="${LOG_DIR}grub_config.log"

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


# if file exists and is regular file
if [ -f $GRUB_CONFIG_FILE ]
then
	echo -e "Backing up current ${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR} to ${YELLOW}${GRUB_CONFIG_FILE_NEW}${NOCOLOR}"

	# just copying a file, moving on
	cp $GRUB_CONFIG_FILE $GRUB_CONFIG_FILE_NEW

	# just adding some whitespace
	echo ""
	ls -lht $GRUB_CONFIG_FILE*
	# adding more whitespace
	echo ""
	
	echo -e "Creating a new ${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR}"

	# silently generate new grub config
	grub-mkconfig > $GRUB_CONFIG_FILE &>/dev/null

	# check last command exit status to see if it failed or not
	if [ $? -eq 0 ]
	then
		echo -e "${GREEN}SUCCESS${NOCOLOR}: ${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR} has been successfully generated."
	else
		echo -e "${RED}FAILURE${NOCOLOR}: ${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR} could not be generated."
	fi
else
	echo -e "${RED}ERROR${NOCOLOR}: ${YELLOW}${GRUB_CONFIG_FILE}${NOCOLOR} does not exist! ${RED}Aborting${NOCOLOR}."
fi

