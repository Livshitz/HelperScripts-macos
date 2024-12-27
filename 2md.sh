#!/bin/bash

# Check if a folder path is provided as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/folder"
  exit 1
fi

# Get the folder path from the first argument
folder="$1"

# Check if the folder exists
if [ ! -d "$folder" ]; then
  echo "Error: Folder '$folder' does not exist."
  exit 1
fi

mkdir "${folder}/md"

# Loop through each PDF in the folder and convert it to Markdown
find "$folder" -type f -name "*.pdf" | while read -r pdf_file; do
  # Extract the base name without extension
  base_name=$(basename "$pdf_file" .pdf)
  # Define the output Markdown file
  md_file="${folder}/md/${base_name}.md"
  # Convert the PDF to Markdown
  markitdown "$pdf_file" > "$md_file"
#   echo markitdown "$pdf_file" -o "$md_file"

  echo "Converted: $pdf_file -> $md_file"
done
