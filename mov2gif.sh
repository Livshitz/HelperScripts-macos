.#!/bin/bash
src=$1
dest=$2
scale=${3:-1}

if [ -z "$dest" ]
then
	dest="${src%.*}.gif"
fi

echo "options: $3 - ${@:4}"
rm $dest
ffmpeg -i $src -vf "scale=iw:ih" -pix_fmt rgb24 -b:v 100000 -r 10 $dest
gifsicle -O5 $dest -o $dest --scale $scale

echo "Done!"


# Convert video to gif file.
# Usage: video2gif video_file (scale) (fps)
# video2gif() {
#   ffmpeg -y -i "${1}" -vf fps=${3:-10},scale=${2:-320}:-1:flags=lanczos,palettegen "${1}.png"
#   ffmpeg -i "${1}" -i "${1}.png" -filter_complex "fps=${3:-10},scale=${2:-320}:-1:flags=lanczos[x];[x][1:v]paletteuse" "${1}".gif
#   rm "${1}.png"
# }
