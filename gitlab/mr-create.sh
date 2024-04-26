export PROJECT_ID=$PROJECT_ID
export GITLAB_PRIVATE_TOKEN=$GITLAB_PRIVATE_TOKEN

# Use current branch's latest commit message as MR title
export TITLE=$(git log -1 --pretty=%B)

# Use current branch as source branch
export SOURCE_BRANCH=$(git branch --show-current)

# Manual input from cmd / terminal / bash
export TARGET_BRANCH=$TARGET_BRANCH

# Gitlab User IDs
# Gitlab numeric User ID can be found in https://gitlab.com/api/v4/users?username=<USERNAME>
export USER_1_ID=123456
export USER_2_ID=345678

declare -a assignee_ids=($USER_1_ID $USER_2_ID)
declare -a reviewer_ids=($USER_1_ID $USER_2_ID)

# Data (-d) are optional except title, source_branch, and target_branch
# For more options https://docs.gitlab.com/ee/api/merge_requests.html#create-mr
curl -X POST \
-H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
-d "title=$TITLE" \
-d "source_branch=$SOURCE_BRANCH" \
-d "target_branch=$TARGET_BRANCH" \
-d "assignee_ids=[${assignee_ids[@]}]" \
-d "reviewer_ids=[${reviewer_ids[@]}]" \
-d "squash=true" \
-d "remove_source_branch=true" \
"https://gitlab.com/api/v4/projects/$PROJECT_ID/merge_requests?private_token=$GITLAB_PRIVATE_TOKEN"