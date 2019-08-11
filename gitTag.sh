set -e && set -o pipefail && cd `pwd`

tag=${1:-'latest'}

git tag "$tag" 
git push --tags