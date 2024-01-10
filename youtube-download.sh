vid=$1
# yt-dlp $vid
# yt-dlp $vid -S res,ext:mp4:m4a --recode mp4
# ffmpeg -fflags +genpts -i "UFO ⧸ UAP Footage Recorded in 4k 60fps with DJI Mavic 3 Pro Cine [Rd-LL0i_ZV8].webm" -r 24 1.mp4
# ffmpeg -i video.webm -crf 1 -c:v libx264 video.mp4

echo "URL=$vid"

# yt-dlp -f 'bestvideo[height<=720]+bestaudio/best' $vid
yt-dlp -f 'bestvideo[height>=2160][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' -S vcodec:h264 --windows-filenames --restrict-filenames --write-auto-subs --sub-lang "en.*" --embed-subs --add-metadata --add-chapters --no-playlist -N 4 -ci --verbose --remux-video "mp4/mkv" $vid

