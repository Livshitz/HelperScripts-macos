#!/bin/bash
branch=${1:-"master"}

curBranch=`git branch | grep \* | cut -d ' ' -f2`
targetBranch=$branch
git pull
git checkout $targetBranch
git pull
git checkout $curBranch 
git merge $targetBranch -m "= merge from $branch" 
git push