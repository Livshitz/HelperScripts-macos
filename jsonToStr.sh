input=${1}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bun $SCRIPT_DIR/src/jsonToStr.ts $input