#!/bin/bash

# ONLY SUPPORT SEMANTIC VERSION

# declare variables
red='\033[0;31m'
default='\033[0m'
changes_type=$3
message=$4

# change some variables if it's invoked directly (without installation).
if [ "$0" == "tag-create.sh" ]
then
  changes_type=$1
  message=$2
fi

# wrap these outputs inside a function to make it cool 😎 
print_suggestion() {
  printf "${red}Error: Invalid command.${default}\\n"
  printf "\\n"
  printf "Available commands with installation\\n"
  printf "  scripts gitlab tag-create major\\n"
  printf "  scripts gitlab tag-create minor\\n"
  printf "  scripts gitlab tag-create patch\\n"
  printf "\\n"
  printf "Available commands without installation\\n"
  printf "  . tag-create.sh major\\n"
  printf "  . tag-create.sh minor\\n"
  printf "  . tag-create.sh patch\\n"

  return 0
}

# validate changes type
if [ "$changes_type" == "" ] || [ "$changes_type" != "major" -a "$changes_type" != "minor" -a "$changes_type" != "patch" ]
then
  print_suggestion
  exit 2
fi

git checkout staging
git pull

# get latest tag
latest_tag=$(git tag -l | tail -1)

# remove "v" from latest tag to get the latest version
latest_version="${latest_tag//v}"

# split version by .
latest_version_arr=(${latest_version//./ })

# get major, minor and patch versions
major=${latest_version_arr[0]}
minor=${latest_version_arr[1]}
patch=${latest_version_arr[2]}

# update version based on changes type given
if [ $changes_type == "major" ]
then
  major=$(( major + 1 ))
  minor="0"
  patch="0"
elif [ $changes_type == "minor" ]
then
  minor=$(( minor + 1 ))
  patch="0"
else
  patch=$(( patch + 1 ))
fi

# value of line below depends on project's naming convention
prefix_branch=release

new_version="$major.$minor.$patch"
new_branch=$prefix_branch/$new_version

# create new branch and checkout to it
git checkout -b $new_branch

# use one of below options to make a new tag
git tag -a v$new_version -m "$message"
# npm version $new_version
# yarn version --new-version $new_version

# push current branch (new branch)
git push origin $(git branch --show-current)

# Get repo_url from git config
repo_url=$(git config --worktree --get remote.origin.url)

# Get path by removing repo_url's prefix ("git@gitlab.com:" or "https://gitlab.com/") and suffix (".git")
# Example: https://gitlab.com/username/repo-name.git  -->  username/repo-name
searchstring="gitlab.com"
rest=${repo_url#*$searchstring}
start_idx=$((${#repo_url} - ${#rest} + 1))
path=${repo_url:start_idx:-4}

tag_link="https://gitlab.com/$path/-/tags/v$new_version"

printf "Tag was published successfully.\\n"
printf "\\n"
printf "see $tag_link\\n"

exit 0