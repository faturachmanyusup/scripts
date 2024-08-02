# ONLY SUPPORT SEMANTIC VERSION

# declare arguments as variables to make it clear
changes_type=$1
message=$2

# declare colors
red='\033[0;31m'
default='\033[0m'

# wrap these outputs inside a function to make it cool 😎 
print_suggestion() {
  echo -e "${red}Error: Invalid command.${default}"
  echo -e ""
  echo -e "Available commands"
  echo -e "   tag-create.sh major"
  echo -e "   tag-create.sh minor"
  echo -e "   tag-create.sh patch"

  return 1
}

# validate changes type
if [ changes_type == "" ] || [ changes_type != "major" -a changes_type != "minor" -a changes_type != "patch" ]
then
  print_suggestion
  return 1
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
patch=${latest_version_arr[2]}

# update version based on changes type given
if [ changes_type == "major" ]
then
  major=$(( major + 1 ))
elif [ changes_type == "minor" ]
then
  minor=$(( minor + 1 ))
else
  patch=$(( patch + 1 ))
fi

# value of line below depends on project's naming convention
prefix_branch=release

new_branch=$prefix_branch/$major.$minor.$patch
new_version="$major.$minor.$patch"

# create new branch and checkout to it
git checkout -b $new_branch

# use one of options below to make a new tag
# git tag -a v$new_version -m "$message"
npm version $new_version
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

echo Tag was published successfully.
echo ""
echo see $tag_link

return 0