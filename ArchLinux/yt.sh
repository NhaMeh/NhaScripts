#!/bin/bash

# use a text file with YT link on each line as input

while read line
do
        echo "$line"
        youtube-dl -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' -o '/media/LData/YouTube/%(title)s [%(id)s].%(ext)s' --restrict-filenames $line
done <$1
