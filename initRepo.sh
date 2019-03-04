#!/bin/bash
repoUrl=$1
echo "Initializing repository for existing and current folder at #$repoUrl!"

git init
git remote add origin $repoUrl
git pull
git add --all
git commit -m 'Init'
git remote -v
git push origin master

echo "Done!"