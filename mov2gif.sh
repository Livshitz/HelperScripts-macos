#!/bin/bash
src=$1
dest=$2

echo "options: ${@:3}"
# ffmpeg -i $src -r 10 $dest
ffmpeg -i $src  -vf "scale=iw/2:ih/2"  -b 100000 -r 10 $dest
gifsicle -O5 $dest -o $dest --scale 0.8 ${@:3}


echo "Done!"

