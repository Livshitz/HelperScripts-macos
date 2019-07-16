curBranch=`git branch | grep \* | cut -d ' ' -f2`
targetBranch=develop
git pull
git checkout $targetBranch
git pull
git checkout $curBranch 
git merge $targetBranch -m "= merge from develop" 
git push
# 1