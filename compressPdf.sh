#!/bin/bash
src="$1"
setting=${2:-/printer}
dest=$3

if [ -z "$dest" ]
then
	dest="${src%.*}-compressed.pdf"
fi

echo "Running ($src, $setting, $dest)"

rm "$dest"

docker run --rm -v $(pwd):/app -w /app minidocks/ghostscript \
	-sDEVICE=pdfwrite \
	-dNOPAUSE \
	-dQUIET \
	-dBATCH \
	-dPDFSETTINGS=$setting \
	-dCompatibilityLevel=1.4 \
	-sColorConversionStrategy=UseDeviceIndependentColor \
	-sOutputFile="$dest" "$src"
	# -dSAFER \
	# -dCompressFonts=true \
	# -dEmbedAllFonts=false \
	# -dOptimize=true \
	# -dColorImageDownsampleType=/Bicubic \
	# -dGrayImageResolution=100 \
	# -dMonoImageResolution=100 \
	# -dDownsampleGrayImages=false \
	# -dDownsampleMonoImages=false \
	# -dDownsampleColorImages=false \
	# -dAutoFilterColorImages=false \
	# -dColorImageDownsampleThreshold=1.0 \
	# -dGrayImageDownsampleThreshold=1.0 \
	# -dMonoImageDownsampleThreshold=1.0 \

	# -dColorImageResolution=120 \

  	# -c ".setpdfwrite <</AlwaysEmbed [ ]>>" \
	# -dEmbedAllFonts=true \
	# -dDetectDuplicateImages=true \
	# -dFastWebView=true \
	# -dPDFA \
	# -dPDFACompatibilityPolicy=1 \

du -sh "$dest"
echo "Done"


# -dPDFSETTINGS=/screen (screen-view-only quality, 72 dpi images)
# -dPDFSETTINGS=/ebook (low quality, 150 dpi images)
# -dPDFSETTINGS=/printer (high quality, 300 dpi images)
# -dPDFSETTINGS=/prepress (high quality, color preserving, 300 dpi imgs)
# -dPDFSETTINGS=/default (almost identical to /screen)