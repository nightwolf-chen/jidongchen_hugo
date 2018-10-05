#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git pull
git add .
git commit -m "$msg"
git push origin master

cd themes/even
git pull
git add .
git commit -m "$msg"
git push origin master

cd ..
cd ..

# Build the project.
hugo -t even # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

git checkout master

git pull

# Add changes to git.
git add .

git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..
