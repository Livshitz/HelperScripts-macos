cd "$(dirname "$0")"

SCRIPT=${1}
ARGS="${@:2}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bun run debug $SCRIPT_DIR/src/$SCRIPT $input $ARGS