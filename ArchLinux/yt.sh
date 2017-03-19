#!/bin/bash

# use a text file with YT link on each line as input

DL_DIR="~/Downloads/YouTube/"

if [ ! -d $DL_DIR ]
then 
	# make the dir
	mkdir -p $DL_DIR
fi

while read LINE
do
	echo "$LINE"
	youtube-dl -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" -o "${DL_DIR}%(title)s [%(id)s].%(ext)s" --restrict-filenames $LINE
done <$1
