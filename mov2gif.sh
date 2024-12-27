#!/bin/bash
src=$1
# dest=$1
scale=${2:-1}
framerate=${3:-10}

if [ -z "$dest" ]
then
	dest="${src%.*}.gif"
fi

echo "options: $scale - ${@:3}"
rm $dest
# ffmpeg -i $src -filter_complex "[0:v] fps=5,scale=iw:ih,split [a][b];[a] palettegen=stats_mode=single [p];[b][p] paletteuse=new=1" -pix_fmt rgb24 -b:v 100000 -r 10 $dest
ffmpeg -i $src -vf "scale=iw:ih" -pix_fmt rgb24  -r $framerate $dest
# ffmpeg -i $src -f gif -r 10 -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse" $dest
gifsicle -O5 $dest -o $dest --scale $scale

echo "Done! Size:"
du -sh $dest


# Convert video to gif file.
# Usage: video2gif video_file (scale) (fps)
# video2gif() {
#   ffmpeg -y -i "${1}" -vf fps=${3:-10},scale=${2:-320}:-1:flags=lanczos,palettegen "${1}.png"
#   ffmpeg -i "${1}" -i "${1}.png" -filter_complex "fps=${3:-10},scale=${2:-320}:-1:flags=lanczos[x];[x][1:v]paletteuse" "${1}".gif
#   rm "${1}.png"
# }
