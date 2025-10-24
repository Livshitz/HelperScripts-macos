#!/bin/bash
src=$1
resolution=${2:-720}
framerate=${3:-24}
keep_original=${4:-false}

if [ -z "$dest" ]
then
	dest="${src%.*}-out.mp4"
fi

echo "options: resolution=$resolution, framerate=$framerate, keep_original=$keep_original - ${@:5}"
# echo "1) $1, 2) $2, 3) $3, dest: $dest"
rm "$dest"

# ffmpeg -i $src $dest
# ffmpeg -i $src -c:v libx264 -preset slow -crf 23 -profile:v high -level 4.0 -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 128k $dest
# ffmpeg -i input.mov -c:v libx264 -preset slow -crf 23 -c:a aac -b:a 128k -movflags +faststart output.mp4
# ffmpeg -i "$src" -c:v libx264 -preset slow -crf 23 -c:a aac -b:a 128k -movflags +faststart -vf "scale=-1:-1,format=yuv420p" -r "$framerate" "$dest"
# ffmpeg -i "$src" -c:v libx264 -preset slow -crf 28 -c:a aac -b:a 96k -movflags +faststart -vf "scale=-1:-1,format=yuv420p" -r "$framerate" "$dest"

# ffmpeg -i "$src" -vf "scale=trunc(iw/2)*2:480" -c:v libx264 -preset veryfast -crf $framerate -c:a aac -b:a 128k -movflags +faststart "$dest"

# Keep original resolution and framerate
if [ "$keep_original" = "true" ]; then
	ffmpeg -i "$src" -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 128k -movflags +faststart -pix_fmt yuv420p "$dest"
else
	# Scale to specified resolution and framerate
	ffmpeg -i "$src" -vf "scale=trunc(oh*a/2)*2:$resolution" -c:v libx264 -preset veryfast -crf $framerate -c:a aac -b:a 128k -movflags +faststart "$dest"
fi

echo "Done! Size:"
du -sh "$src"
du -sh "$dest"


# Convert mov/webm video to mp4 file.
# Usage: mov2mp4 video_file [resolution] [framerate] [keep_original]
# Example: mov2mp4 input.mov 30 1080
# Example (keep original): mov2mp4 input.webm 0 0 true
# Defaults: resolution=720, framerate=24, keep_original=false


# Replace `input.mov` with the name of your .mov file and `output.mp4` with the desired name for the converted .mp4 file.

# This command uses the following settings:

# - `-c:v libx264`: Use the H.264 video codec.
# - `-preset slow`: Use the slow preset for better compression (you can use `medium` or `fast` for faster conversion with slightly larger file sizes).
# - `-crf 23`: Set the Constant Rate Factor (CRF) to 23 for a balance between quality and file size (lower values produce better quality but larger files).
# - `-profile:v high -level 4.0`: Set the H.264 profile to High and level to 4.0 for better compatibility with modern devices.
# - `-pix_fmt yuv420p`: Use the YUV 4:2:0 pixel format for better compatibility.
# - `-movflags +faststart`: Move the metadata to the beginning of the file for faster streaming.
# - `-c:a aac`: Use the AAC audio codec.
# - `-b:a 128k`: Set the audio bitrate to 128 kbps.

# After the conversion is complete, you'll have an optimized .mp4 file for web use.