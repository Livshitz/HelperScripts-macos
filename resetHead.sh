#!/bin/bash
COMMIT=$1
echo "Resetting current working git to commit #$COMMIT!"

git reset $COMMIT
git reset --soft HEAD@{1}
git commit -m "Revert to $COMMIT"
git reset --hard


echo "Done!"