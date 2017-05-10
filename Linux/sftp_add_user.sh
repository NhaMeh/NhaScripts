#!/bin/bash

# colors. yea.
RED='\033[0;31m'
YELLOW='\033[93m'
NOCOLOR='\033[0m'

USERNAME=""
PASSWORD=""
P=0
G=0
SFTP_ROOT_DIR="/data/SFTP"
SFTP_GROUP="sftpusers"

function error() {
	echo -e "${RED}Error${NOCOLOR}: ${@}"
}

# if no arguments
if [ $# -eq 0 ]
then
	echo -e "Add an SFTP user."
	echo -e "Usage:"
	echo -e "  ${YELLOW}-u <username>${NOCOLOR}        username."
	echo -e "  ${YELLOW}-p <password>${NOCOLOR}        password."
	echo -e "  ${YELLOW}-g <length>${NOCOLOR}         generate password, minimum length is 8."
	echo ""
	echo -e "If no password is given you will be prompted for one."

	exit 0
fi

# parses options -u, -g, and -p with arguments
#   if an argument to these options is provided it will be placed in OPTARG
#   if no argument is provided getopts will set opt to : so we can catch
#   this as an error
while getopts ":u:p:g:" opt
do
	case ${opt} in
		u )
			USERNAME=$OPTARG
			;;
		p )
			PASSWORD=$OPTARG
			P=1
			;;
		g )
			LENGTH=$OPTARG

			if [ $LENGTH -lt 8 ]
			then
				LENGTH=8
			fi

			PASSWORD=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n ${LENGTH} | tr -d '\n';echo`
			G=1
			;;
		: )
			error "option ${YELLOW}${OPTARG}${NOCOLOR} requires arguments."
			exit 1
			;;
	esac
done

# remove options already handled from $@
shift $((OPTIND -1))

if [ $P -eq 1 ] && [ $G -eq 1 ]
then
	error "specifying a password AND generating one is not the greatest idea. Try again."
fi

if [ "$USERNAME" == "" ]
then
	error "username cannot be empty."
	exit 1
fi

if [ "$PASSWORD" == "" ]
then
	error "password cannot be empty."
	echo -e "Enter ${YELLOW}password${NOCOLOR} now:"
	read PASSWORD
fi

if [[ ! $USERNAME =~ ^[A-Za-z0-9]+$ ]]
then
	error "unsupported characters in username ${YELLOW}${USERNAME}${NOCOLOR}. Please use only alphanumeric characters."
	exit 1
fi

if [[ ! $PASSWORD =~ ^[A-Za-z0-9]+$ ]]
then
	error "unsupported characters in password. Please use only alphanumeric characters."
	exit 1
fi

id ${USERNAME} &>/dev/null

if [ $? -eq 0 ]
then
	error "username ${YELLOW}${USERNAME}${NOCOLOR} already exists."
	exit 1
fi

SFTP_USER_DIR="${SFTP_ROOT_DIR}/${USERNAME}"
SFTP_USER_DIR_DATA="${SFTP_USER_DIR}/data"

if [ -d "$SFTP_USER_DIR" ]
then
	error "folder ${YELLOW}${SFTP_USER_DIR}${NOCOLOR} already exists, not creating anything."
	exit 1
fi

if [ $G -eq 1 ]
then
	echo -e "${YELLOW}Password${NOCOLOR}: "
	echo $PASSWORD
fi

# I'm just assuming nothing will go wrong beyond this point, tired of checking stuff.

useradd -G sftpusers ${USERNAME} &>/dev/null
echo ${USERNAME}:${PASSWORD} | chpasswd

mkdir ${SFTP_USER_DIR}
chmod 755 ${SFTP_USER_DIR}
chown root:root ${SFTP_USER_DIR}

mkdir ${SFTP_USER_DIR_DATA}
chown ${USERNAME}:${SFTP_GROUP} ${SFTP_USER_DIR_DATA}
