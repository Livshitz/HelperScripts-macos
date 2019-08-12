echo "pwd: " `pwd`
set -e && set -o pipefail && cd `pwd`

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

exit 0

if [ -z "$dest" ]
then
	dest="${src%.*}.gif"
fi

# if [ "$1" = "x" ]; then echo "yo"; fi

IS_CI=${1:-false}
echo "IS_CI=${IS_CI}"
if ! $IS_CI; then echo "yo"; fi

exit 1