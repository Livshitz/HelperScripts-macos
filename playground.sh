echo "pwd: " `pwd`
set -e && set -o pipefail && cd `pwd`

if [ -z "$dest" ]
then
	dest="${src%.*}.gif"
fi

# if [ "$1" = "x" ]; then echo "yo"; fi

IS_CI=${1:-false}
echo "IS_CI=${IS_CI}"
if ! $IS_CI; then echo "yo"; fi

exit 1