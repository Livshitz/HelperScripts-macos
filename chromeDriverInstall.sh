# Usage: \curl -sSL https://raw.githubusercontent.com/Livshitz/HelperScripts-macos/master/chromeDriverInstall.sh | bash -s mac64 76.0.3809.25

set -e

CHROMEDRIVER_VERSION=${1:-"76.0.3809.25"}
ARCH=${2:-"mac64"}
CACHED_DOWNLOAD="${HOME}/cache/chromedriver_$ARCH_${CHROMEDRIVER_VERSION}.zip"

CHACHEDIR=`dirname $CACHED_DOWNLOAD`
mkdir -p $CHACHEDIR

wget --continue --output-document "${CACHED_DOWNLOAD}" "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_$ARCH.zip"

rm -rf "/usr/local/bin/chromedriver"
unzip -o "${CACHED_DOWNLOAD}" -d "/usr/local//bin"

rm -rf $CACHED_DOWNLOAD
