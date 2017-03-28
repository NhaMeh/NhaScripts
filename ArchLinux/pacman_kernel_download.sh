#!/bin/bash

declare -a ARRAY=("linux-ck-sandybridge" "linux-ck-sandybridge-headers" "broadcom-wl-ck-sandybridge" "virtualbox-ck-host-modules-sandybridge")

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
GREEN='\033[92m'
NOCOLOR='\033[0m'

DL_DIR="/root/.kernel/"

# set to 0 to disable logging
LOGGING=1
LOG_DIR="/var/log/nha/"
LOG_FILE="${LOG_DIR}pacman_kernel_download.log"

SUCCESS="${GREEN}SUCCESS${NOCOLOR}: "
FAILURE="${RED}FAILURE${NOCOLOR}: "

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

function main {
	if [ $LOGGING -eq 1 ]
	then
		check_log_dir
		check_log_file
	fi

	# update the repos, otherwise an older version might creep in and get 404's
	pacman -Syy

	for PKG in "${ARRAY[@]}"
	do
		PKG_NAME="$(pacman -Ss ${PKG} | sed -n '1p' | awk -F '/' '{print $2}' | awk '{print $1}')"
		PKG_VER="$(pacman -Ss ${PKG} | sed -n '1p' | awk '{print $2}')"
		PKG_DIR="${DL_DIR}${PKG_NAME}/${PKG_VER}/"
		PKG_FILE_NAME="${PKG_NAME}-${PKG_VER}-x86_64.pkg.tar.xz"
		PKG_FILE="${PKG_DIR}${PKG_FILE_NAME}"
		PKG_Y="${YELLOW}${PKG_NAME} ${PKG_VER}${NOCOLOR}"
		PKG_FILE_Y="${YELLOW}${PKG_FILE_NAME}${NOCOLOR}"

		if [ ! -d $PKG_DIR ]
		then
			mkdir -p $PKG_DIR
		fi

		if [ ! -f $PKG_FILE ]
		then
			output "Downloading ${PKG_Y}."

			yes | pacman -Sw --cachedir $PKG_DIR $PKG

			if [ $? -eq 0 ]
			then
				output "${SUCCESS}${PKG_Y} was successfully downloaded."
			else
				output "${FAILURE}${PKG_Y} could not be downloaded."
			fi
		else
			output "${SUCCESS}Skipping download, ${PKG_FILE_Y} already exists."
		fi
	done
}

main
