#!/bin/bash

# The $EUID environment variable holds the current user's UID. Root's UID is 0.
# check if the user running the script is root, otherwise su first
if [ "$EUID" -ne 0 ]
then
	su - root -c "whoami"
else
	whoami
fi
