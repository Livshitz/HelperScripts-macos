#!/bin/bash

# if [ $# -ne 3 ]; then
#   echo "Usage: $0 input_file scale_ratio"
#   exit 1
# fi

src=$1
SCALE_RATIO=$2
BITRATE_RATIO=${3:-$SCALE_RATIO} 
OUTPUT_FOLDER=${4:-'./'}

filename_with_extension=$(basename "$src")
filename_without_extension="${filename_with_extension%.*}"

filename_with_extension=$(basename "$src")
filename_without_extension="${filename_with_extension%.*}"

if [ -z "$OUTPUT_FOLDER" ]
then
	dest="${src%.*}-out.mp4"
else 
	dest="$OUTPUT_FOLDER${filename_without_extension}-out.mp4"
fi

# mkdir -p "$dest"

# Get original bitrate using ffprobe
ORIGINAL_BITRATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$src")

# Convert bitrate from bits to kilobits
ORIGINAL_BITRATE=$(echo "$ORIGINAL_BITRATE / 1000" | bc)

# Calculate new bitrate
NEW_BITRATE=$(echo "$ORIGINAL_BITRATE * $BITRATE_RATIO * $BITRATE_RATIO" | bc)

# Get original width and height
WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$src")
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$src")

# Calculate new width and height, ensuring they are even
NEW_WIDTH=$(echo "2 * ($WIDTH * $SCALE_RATIO / 2 + 0.5) / 2" | bc)
NEW_HEIGHT=$(echo "2 * ($HEIGHT * $SCALE_RATIO / 2 + 0.5) / 2" | bc)

# ffmpeg -i "${src}" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k $dest

echo "----"
echo "config: src:$src, scale:$SCALE_RATIO, bitrateScale:$BITRATE_RATIO, bitrate:$NEW_BITRATE, dest:$dest"
echo "----"

# ffmpeg -i "$src" -vf "scale=$NEW_WIDTH:$NEW_HEIGHT" -b:v "${NEW_BITRATE}k" -c:a copy "$dest"

ffmpeg -i "$src" -vf "scale=iw*$SCALE_RATIO:ih*$SCALE_RATIO" -b:v "${NEW_BITRATE}k" -c:a copy "$dest" -loglevel error -y

du -sh "$src"
du -sh "$dest"