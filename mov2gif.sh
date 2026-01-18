#!/bin/bash
src="${1//\\/}"
# dest=$1
scale=${2:-1}

# Check if framerate was explicitly provided
if [ -n "$3" ] && [[ "$3" =~ ^[0-9]+$ ]]; then
	framerate=$3
	fps_explicit=true
else
	framerate=10
	fps_explicit=false
fi

# Check for flags
boomerang=false
optimize=false
optimize_level=0
for arg in "$@"; do
	if [[ "$arg" == "-b" || "$arg" == "--boomerang" ]]; then
		boomerang=true
	fi
	if [[ "$arg" == "-o2" ]]; then
		optimize=true
		optimize_level=2
	elif [[ "$arg" == "-o" || "$arg" == "--optimize" ]]; then
		optimize=true
		optimize_level=1
	fi
done

if [ -z "$dest" ]
then
	dest="${src%.*}.gif"
fi

echo "options: $scale - ${@:3}"
if [ "$boomerang" = true ]; then
	echo "Boomerang mode enabled"
fi
if [ "$optimize" = true ]; then
	if [ "$optimize_level" = "2" ]; then
		echo "Ultra brutal optimization enabled (-o2)"
		# More aggressive than -o: fewer colors, same dither, higher lossy
		max_colors=56
		dither_mode="bayer:bayer_scale=3"  
		lossy_level=150  # Sweet spot for aggressive compression
	else
		echo "Brutal optimization enabled (-o)"
		# Balanced: good colors, moderate dither, moderate lossy
		max_colors=64
		dither_mode="bayer:bayer_scale=3"
		lossy_level=120
	fi
fi
# Keep input resolution in ffmpeg, let gifsicle handle scaling via --scale parameter
scale_filter="scale=iw:ih:flags=lanczos"
rm "$dest"

if [ "$optimize" = true ]; then
	# Two-pass palette generation with reduced colors for brutal optimization
	palette="${dest%.*}_palette.png"
	if [ "$boomerang" = true ]; then
		# Generate palette with boomerang effect
		ffmpeg -i "$src" -filter_complex "[0:v]fps=$framerate,$scale_filter,split[forward][reverse];[reverse]reverse[r];[forward][r]concat=n=2:v=1,palettegen=stats_mode=diff:max_colors=$max_colors" "$palette"
		# Generate GIF with optimized palette
		ffmpeg -i "$src" -i "$palette" -filter_complex "[0:v]fps=$framerate,$scale_filter,split[forward][reverse];[reverse]reverse[r];[forward][r]concat=n=2:v=1[x];[x][1:v]paletteuse=dither=$dither_mode:diff_mode=rectangle" "$dest"
	else
		# Generate palette
		ffmpeg -i "$src" -vf "fps=$framerate,$scale_filter,palettegen=stats_mode=diff:max_colors=$max_colors" "$palette"
		# Generate GIF with optimized palette
		ffmpeg -i "$src" -i "$palette" -filter_complex "fps=$framerate,$scale_filter[x];[x][1:v]paletteuse=dither=$dither_mode:diff_mode=rectangle" "$dest"
	fi
	rm "$palette"
elif [ "$boomerang" = true ]; then
	# Create boomerang effect: forward + reverse using ffmpeg concat filter
	ffmpeg -i "$src" -filter_complex "[0:v]scale=iw:ih,split[forward][reverse];[reverse]reverse[r];[forward][r]concat=n=2:v=1[out]" -map "[out]" -pix_fmt rgb24 -r $framerate "$dest"
else
	ffmpeg -i "$src" -vf "scale=iw:ih" -pix_fmt rgb24  -r $framerate "$dest"
fi
# ffmpeg -i "$src" -filter_complex "[0:v] fps=5,scale=iw:ih,split [a][b];[a] palettegen=stats_mode=single [p];[b][p] paletteuse=new=1" -pix_fmt rgb24 -b:v 100000 -r 10 "$dest"
# ffmpeg -i "$src" -f gif -r 10 -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse" "$dest"
if command -v gifsicle &> /dev/null; then
	if [ "$optimize" = true ]; then
		# Brutal optimization: lossy compression + reduced colors
		gifsicle -O3 --lossy=$lossy_level --colors=$max_colors "$dest" -o "$dest" --scale $scale
	else
		gifsicle -O5 "$dest" -o "$dest" --scale $scale
	fi
elif [ "$scale" != "1" ]; then
	echo "Warning: gifsicle not found, scale parameter ignored. Install gifsicle for optimization."
fi

echo "Done! Size:"
du -sh "$dest"


# Convert video to gif file.
# Usage: video2gif video_file (scale) (fps)
# video2gif() {
#   ffmpeg -y -i "${1}" -vf fps=${3:-10},scale=${2:-320}:-1:flags=lanczos,palettegen "${1}.png"
#   ffmpeg -i "${1}" -i "${1}.png" -filter_complex "fps=${3:-10},scale=${2:-320}:-1:flags=lanczos[x];[x][1:v]paletteuse" "${1}".gif
#   rm "${1}.png"
# }
