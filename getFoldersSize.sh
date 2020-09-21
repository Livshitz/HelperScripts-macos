target=${1:-'.'}

# du -hs $target* | sort -hs

du -d1 -h $target* | sort -hr 