#!/usr/bin/env bash

SCRIPT="$1"
shift  # Shift all args to the left, so $@ now contains only the script arguments

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bun "$SCRIPT_DIR/src/$SCRIPT" "$@"
