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

# Use current branch as source branch
export SOURCE_BRANCH=$(git branch --show-current)

# Parse arguments
CUSTOM_TITLE=""
TARGET_BRANCH=""
DRAFT_FLAG=""

# Check if script is invoked directly or through the scripts command
if [ "$0" == "mr-create.sh" ]; then
  # Direct invocation
  args=("$@")
else
  # Invocation through scripts command (skip first two arguments: provider and action)
  args=("${@:3}")
fi

# Parse arguments
i=0
while [ $i -lt ${#args[@]} ]; do
  if [ "${args[$i]}" == "-m" ]; then
    # Next argument is the custom title
    i=$((i+1))
    if [ $i -lt ${#args[@]} ]; then
      CUSTOM_TITLE="${args[$i]}"
    else
      printf "${red}Error: -m flag requires a title argument.${no_color}\\n"
      exit 2
    fi
  elif [ "${args[$i]}" == "--draft" ]; then
    # Set draft flag
    DRAFT_FLAG="true"
  elif [ -z "$TARGET_BRANCH" ]; then
    # First non-flag argument is the target branch
    TARGET_BRANCH="${args[$i]}"
  fi
  i=$((i+1))
done

# Set MR title - use custom title if provided, otherwise use latest commit message
if [ -n "$CUSTOM_TITLE" ]; then
  export TITLE="$CUSTOM_TITLE"
else
  export TITLE=$(git log -1 --pretty=%B)
fi

# Validate TARGET_BRANCH
if [ "$TARGET_BRANCH" = "" ]
then
  printf "${red}Error: TARGET_BRANCH should not be empty.${no_color}\\n"
  printf "\\n"
  printf "With installation:\\n"
  printf "  scripts gitlab mr-create <TARGET_BRANCH> [-m \"MR Title\"] [--draft]\\n"
  printf "  scripts gitlab mr-create -m \"MR Title\" <TARGET_BRANCH> [--draft]\\n"
  printf "  scripts gitlab mr-create --draft <TARGET_BRANCH> [-m \"MR Title\"]\\n"
  printf "\\n"
  printf "Without installation:\\n"
  printf "  . mr-create.sh <TARGET_BRANCH> [-m \"MR Title\"] [--draft]\\n"
  printf "  . mr-create.sh -m \"MR Title\" <TARGET_BRANCH> [--draft]\\n"
  printf "  . mr-create.sh --draft <TARGET_BRANCH> [-m \"MR Title\"]\\n"

  exit 2
fi

# Gitlab Numeric User IDs
# Gitlab numeric User ID can be found on https://gitlab.com/api/v4/users?username=<USERNAME>
# Get ASSIGNEE_ID from git config
# ASSIGNEE_ID can be set using "git config --worktree --add remote.origin.assigneeid <VALUE>"
export ASSIGNEE_ID=$(git config --worktree --get remote.origin.assigneeid)

# Validate ASSIGNEE_ID
if [ "$ASSIGNEE_ID" = "" ]
then
  printf "${red}Error: ASSIGNEE_ID should not be empty.${no_color}\\n"
  printf "\\n"
  printf "You can set ASSIGNEE_ID using "'"git config --worktree --add remote.origin.assigneeid <VALUE>"'"\\n"
  printf "Gitlab numeric User ID can be found on https://gitlab.com/api/v4/users?username=<USERNAME>\\n"

  exit 2
fi

export REVIEWER_ID=567890

# Data (-d) are optional except title, source_branch, and target_branch
# For more options https://docs.gitlab.com/ee/api/merge_requests.html#create-mr

# Build curl command with optional draft parameter
CURL_OPTS=(
  -s -X POST
  -H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN"
  -d "title=$TITLE"
  -d "source_branch=$SOURCE_BRANCH"
  -d "target_branch=$TARGET_BRANCH"
  -d "assignee_id=$ASSIGNEE_ID"
  -d "reviewer_ids=$REVIEWER_ID"
  -d "squash=true"
  -d "remove_source_branch=true"
)

if [ "$DRAFT_FLAG" = "true" ]; then
  CURL_OPTS+=(-d "draft=true")
fi

export response=$(
  curl "${CURL_OPTS[@]}" \
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
if [ "$DRAFT_FLAG" = "true" ]; then
  printf "Draft MR successfully created. Your MR ready on:\\n"
else
  printf "MR successfully created. Your MR ready on:\\n"
fi
printf "\\n"
printf "$mr_link\\n"

exit 0