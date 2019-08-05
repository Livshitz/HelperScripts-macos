# Usage: \curl -sSL https://raw.githubusercontent.com/Livshitz/HelperScripts-macos/master/chromeDriverInstall.sh | bash -s mac64 76.0.3809.25

set -e

ARCH=${1:-"mac64"}
CHROMEDRIVER_VERSION=${2:-"76.0.3809.25"}
CACHED_DOWNLOAD="${HOME}/cache/chromedriver_$ARCH_${CHROMEDRIVER_VERSION}.zip"

CHACHEDIR=`dirname $CACHED_DOWNLOAD`
mkdir -p $CHACHEDIR

wget --continue --output-document "${CACHED_DOWNLOAD}" "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_$ARCH.zip"

rm -rf "${HOME}/bin/chromedriver"
unzip -o "${CACHED_DOWNLOAD}" -d "${HOME}/bin"

rm -rf $CACHED_DOWNLOAD
