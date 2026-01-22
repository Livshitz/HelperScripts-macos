#!/bin/bash
src=$1
bitrate=${2:-128k}
samplerate=${3:-44100}
channels=${4:-2}
vbr_quality=$5
dest=${6:-"${src%.*}.mp3"}

if [ -z "$src" ]; then
	echo "Usage: mov2mp3 video_file [bitrate] [samplerate] [channels] [vbr_quality] [dest]"
	echo "Example: mov2mp3 input.mov 96k 32000 1"
	echo "Example (VBR): mov2mp3 input.mp4 0 0 0 5 output.mp3"
	exit 1
fi

echo "options: bitrate=$bitrate, samplerate=$samplerate, channels=$channels, vbr_quality=$vbr_quality, dest=$dest"

audio_args=()
if [ -n "$samplerate" ] && [ "$samplerate" != "0" ]; then
	audio_args+=(-ar "$samplerate")
fi
if [ -n "$channels" ] && [ "$channels" != "0" ]; then
	audio_args+=(-ac "$channels")
fi

if [ -f "$dest" ]; then
	rm "$dest"
fi

if [ -n "$vbr_quality" ]; then
	ffmpeg -i "$src" -vn -c:a libmp3lame -q:a "$vbr_quality" "${audio_args[@]}" "$dest"
else
	bitrate_args=()
	if [ -n "$bitrate" ] && [ "$bitrate" != "0" ]; then
		bitrate_args=(-b:a "$bitrate")
	fi
	ffmpeg -i "$src" -vn -c:a libmp3lame "${bitrate_args[@]}" "${audio_args[@]}" "$dest"
fi

echo "Done! Size:"
du -sh "$src"
du -sh "$dest"

# Extract mp3 audio from video file.
# Usage: mov2mp3 video_file [bitrate] [samplerate] [channels] [vbr_quality] [dest]
# Example: mov2mp3 input.mov 128k 44100 2
# Example (smaller): mov2mp3 input.mp4 96k 32000 1
# Example (VBR): mov2mp3 input.mp4 0 0 0 5 output.mp3
# Note: set samplerate/channels to 0 to keep original.
# Defaults: bitrate=128k, samplerate=44100, channels=2, vbr_quality=""
