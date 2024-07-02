#!/bin/bash
INPUT_FOLDER=$1
OUTPUT_FOLDER=$2
SCALE_RATIO=${3:-0.4}  # Default scale ratio to 0.8 if not provided
BITRATE_RATIO=${4:-$SCALE_RATIO}  # Fallback to scale ratio if bitrate ratio is not provided

# SCRIPT_DIR=$(dirname "$(realpath "$0")")
DIR=$(pwd)
DEST_PATH="$DIR/$OUTPUT_FOLDER"

# Create output folder if it doesn't exist
mkdir -p "$DEST_PATH"

# Array of video file extensions
EXTENSIONS=("mp4" "avi" "mkv" "mov" "flv" "wmv" "webm" "mpeg" "mpg")

echo "$INPUT_FOLDER - $DEST_PATH - $SCALE_RATIO - $BITRATE_RATIO"

# Loop through each extension and process the files
for EXT in "${EXTENSIONS[@]}"; do
    # Find files with the current extension
    # FILES=$(find "$INPUT_FOLDER" -maxdepth 1 -type f -name "*.$EXT")
    
	find "$INPUT_FOLDER" -maxdepth 1 -type f -name "*.$EXT" | while read -r FILE; do
    
	# Loop through each found file
	# echo "file: $FILES"

    # for FILE in $FILES; do
        # Execute the command with the current file
		# FILENAME=$(basename "$FILE" ".$EXT")
		
		# echo file: "$FILE"
		mp4-compress.sh "$FILE" $SCALE_RATIO $BITRATE_RATIO "$DEST_PATH/" 
    done
done
