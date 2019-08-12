#!/bin/bash
set -e && set -o pipefail # && cd `pwd`

target=${1}
trashDir="$HOME/Desktop/Temp/"

mkdir -p $trashDir

if [ -z "$target" ]
  then
    echo "ERROR! No target supplied"
fi

mv "$target" "$trashDir"