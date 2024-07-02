#!/bin/bash
src=$1
# dest=$1
scale=${2:-80}

ext="jpeg"

if [ -z "$dest" ]
then
	dest="${src%.*}.$ext"
fi

sips -s format jpeg -s formatOptions $scale $src --out $dest
# echo sips -s format jpeg -s formatOptions $scale $src --out $dest

du -sh $src
du -sh $dest


# Convert video to gif file.
# Usage: video2gif video_file (scale) (fps)
# video2gif() {
#   ffmpeg -y -i "${1}" -vf fps=${3:-10},scale=${2:-320}:-1:flags=lanczos,palettegen "${1}.png"
#   ffmpeg -i "${1}" -i "${1}.png" -filter_complex "fps=${3:-10},scale=${2:-320}:-1:flags=lanczos[x];[x][1:v]paletteuse" "${1}".gif
#   rm "${1}.png"
# }
