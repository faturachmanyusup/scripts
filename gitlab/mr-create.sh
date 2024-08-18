#!/bin/bash

export GITLAB_PRIVATE_TOKEN=$GITLAB_PRIVATE_TOKEN
export red='\033[0;31m'
export no_color='\033[0m'

# Validate GITLAB_PRIVATE_TOKEN
if [ "$GITLAB_PRIVATE_TOKEN" = "" ]
then
  printf "${red}Error: GITLAB_PRIVATE_TOKEN should not be empty.${no_color}\\n"
  printf "\\n"
  printf "You can set GITLAB_PRIVATE_TOKEN using "'"export GITLAB_PRIVATE_TOKEN=<VALUE>"'"\\n"

  exit 2
fi

# Get PROJECT_ID from git config
# PROJECT_ID can be set using "git config --worktree --add remote.origin.projectid <VALUE>"
export PROJECT_ID=$(git config --worktree --get remote.origin.projectid)

# Validate PROJECT_ID
if [ "$PROJECT_ID" = "" ]
then
  printf "${red}Error: PROJECT_ID should not be empty.${no_color}\\n"
  printf "\\n"
  printf "You can set PROJECT_ID using "'"git config --worktree --add remote.origin.projectid <VALUE>"'"\\n"

  exit 2
fi

# Use current branch's latest commit message as MR title
export TITLE=$(git log -1 --pretty=%B)

# Use current branch as source branch
export SOURCE_BRANCH=$(git branch --show-current)

# Take second argument ($3) as target branch if it's not invoked directly, otherwise take first argument ($1).
export TARGET_BRANCH=$3
if [ "$0" == "mr-create.sh" ]
then
  TARGET_BRANCH=$1
fi

# Validate TARGET_BRANCH
if [ "$TARGET_BRANCH" = "" ]
then
  printf "${red}Error: TARGET_BRANCH should not be empty.${no_color}\\n"
  printf "\\n"
  printf "With installation:\\n"
  printf "  scripts mr-create gitlab <TARGET_BRANCH>\\n"
  printf "\\n"
  printf "Without installation:\\n"
  printf "  . mr-create.sh <TARGET_BRANCH>\\n"

  exit 2
fi

# Gitlab Numeric User IDs
# Gitlab numeric User ID can be found on https://gitlab.com/api/v4/users?username=<USERNAME>
export ASSIGNEE_ID=123456
export REVIEWER_ID=567890

# Data (-d) are optional except title, source_branch, and target_branch
# For more options https://docs.gitlab.com/ee/api/merge_requests.html#create-mr
export response=$(
  curl -s -X POST \
    -H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
    -d "title=$TITLE" \
    -d "source_branch=$SOURCE_BRANCH" \
    -d "target_branch=$TARGET_BRANCH" \
    -d "assignee_id=$ASSIGNEE_ID" \
    -d "reviewer_ids=$REVIEWER_ID" \
    -d "squash=true" \
    -d "remove_source_branch=true" \
    "https://gitlab.com/api/v4/projects/$PROJECT_ID/merge_requests?private_token=$GITLAB_PRIVATE_TOKEN"
)

mr_id=$(echo $response | jq -r '.iid')

# Check response. Exit if response is error.
if [ "$mr_id" = "null" ]
then
  red='\033[0;31m'
  err_msg=$(echo $response | jq -r '.message')

  printf "${red}Error: MR cannot be created.\\n"
  printf "\\n"
  printf "reason: $err_msg\\n"

  exit 2
fi

# Get repo_url from git config
repo_url=$(git config --worktree --get remote.origin.url)

# Get path by removing repo_url's prefix ("git@gitlab.com:" or "https://gitlab.com/") and suffix (".git")
# Example: https://gitlab.com/username/repo-name.git  -->  username/repo-name   
searchstring="gitlab.com"
rest=${repo_url#*$searchstring}
start_idx=$((${#repo_url} - ${#rest} + 1))
path=${repo_url:start_idx:-4}

mr_link="https://gitlab.com/$path/-/merge_requests/$mr_id"

# Print it to terminal / bash
printf "Hello @everyone, please help me to review my work.\\n"
printf "\\n"
printf "$mr_link\\n"

exit 0