#!/bin/bash
repoUrl=$1
echo "Initializing repository for existing and current folder at #$repoUrl!"

git init
git remote add origin $repoUrl
git remote -v
git pull origin master
git add --all
git commit -m 'Init'
git push origin master

echo "Done!"