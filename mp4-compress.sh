#!/bin/bash
src=$1

if [ -z "$dest" ]
then
	dest="${src%.*}-out.mp4"
fi

ffmpeg -i "${src}" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k $dest