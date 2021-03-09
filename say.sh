#!/bin/bash
set -e && set -o pipefail && cd `pwd`
text=$1
output=${2:-say.mp3}
voice=${3:-Carmit}

echo "options: $text, $output, $voice  - ${@:3}"


say -v $voice $text -o temp.aiff
lame -m m temp.aiff $output
rm temp.aiff
afplay $output