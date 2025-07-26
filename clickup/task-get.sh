#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'
green='\033[0;32m'

# Parse command line arguments
assignees=""
list_id=""
team_id=""
status_filter=""
only_me=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--assignees)
      assignees="$2"
      shift 2
      ;;
    -l|--list)
      list_id="$2"
      shift 2
      ;;
    -t|--team)
      team_id="$2"
      shift 2
      ;;
    --only-me|-me)
      only_me=true
      shift
      ;;
    -s|--status)
      status_filter="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Validate CU_PERSONAL_TOKEN
if [ "$CU_PERSONAL_TOKEN" = "" ]; then
  printf "${red}Error: CU_PERSONAL_TOKEN should not be empty.\\n"
  printf "${no_color}\\n"
  printf "You can set CU_PERSONAL_TOKEN using \"export CU_PERSONAL_TOKEN=<VALUE>\"\\n"
  exit 2
fi

# Validate that either list_id or team_id is provided
if [ "$list_id" = "" ] && [ "$team_id" = "" ]; then
  printf "${red}Error: Either List ID or Team ID is required.\\n"
  printf "${no_color}\\n"
  printf "Usage:\\n"
  printf "  task-get.sh -l <LIST_ID> [-a <ASSIGNEE_IDS>] [-s <STATUS>] [-me]  # Get tasks from specific list\\n"
  printf "  task-get.sh -t <TEAM_ID> [-a <ASSIGNEE_IDS>] [-s <STATUS>] [-me] # Get tasks from team\\n"
  printf "Examples:\\n"
  printf "  task-get.sh -l 123456789 -a \"12345,67890\" -s \"in progress\"\\n"
  printf "  task-get.sh -t 987654321 -s \"to do\" -me\\n"
  printf "  task-get.sh -l 123456789 -me -s \"in progress\"\\n"
  exit 2
fi

# Get user ID if --only-me flag is used
user_id=""
if [ "$only_me" = true ]; then
  user_response=$(
    curl -s -X GET \
      "https://api.clickup.com/api/v2/user" \
      -H "Authorization: $CU_PERSONAL_TOKEN"
  )
  
  user_id=$(echo "$user_response" | jq -r '.user.id')
  
  if [ "$user_id" = "null" ] || [ "$user_id" = "" ]; then
    printf "${red}Failed to get user ID.\\n"
    printf "${no_color}\\n"
    exit 2
  fi
  
  # Override assignees with user ID if --only-me is used
  assignees="$user_id"
fi

# Build API URL based on list or team
if [ "$list_id" != "" ]; then
  api_url="https://api.clickup.com/api/v2/list/$list_id/task"
  
  # Build query parameters
  params=""
  if [ "$assignees" != "" ]; then
    params="assignees[]=$assignees"
  fi
  
  if [ "$status_filter" != "" ]; then
    # URL encode the status (replace spaces with %20)
    encoded_status=$(echo "$status_filter" | sed 's/ /%20/g')
    if [ "$params" != "" ]; then
      params="$params&statuses[]=$encoded_status"
    else
      params="statuses[]=$encoded_status"
    fi
  fi
  
  if [ "$params" != "" ]; then
    api_url="$api_url?$params"
  fi
else
  # Build team endpoint URL
  api_url="https://api.clickup.com/api/v2/team/$team_id/task"
  
  # Build query parameters
  params=""
  if [ "$assignees" != "" ]; then
    params="assignees[]=$assignees"
  fi
  
  if [ "$params" != "" ]; then
    api_url="$api_url?$params"
  fi
fi



# Make HTTP Request to get tasks
response=$(
  curl -s -X GET \
    "$api_url" \
    -H "Authorization: $CU_PERSONAL_TOKEN"
)

# Validate response
if echo "$response" | grep -q "</html>"; then
  printf "${red}Failed to get tasks.\\n"
  printf "${no_color}\\n"
  printf "Please check your LIST_ID and CU_PERSONAL_TOKEN\\n"
  exit 2
fi

# Check if response contains error
if echo "$response" | jq -e '.err' > /dev/null 2>&1; then
  error_msg=$(echo "$response" | jq -r '.err')
  printf "${red}Error: $error_msg\\n"
  printf "${no_color}\\n"
  exit 2
fi

# Apply status filter locally for team endpoint
if [ "$team_id" != "" ] && [ "$status_filter" != "" ]; then
  # Filter by status locally using jq
  filtered_response=$(echo "$response" | jq --arg status "$status_filter" '{tasks: [.tasks[] | select(.status.status == $status)]}')
  response="$filtered_response"
fi

# Parse and display tasks
tasks=$(echo "$response" | jq -r '.tasks[]')

if [ "$tasks" = "" ]; then
  printf "${green}No tasks found.\\n"
  printf "${no_color}\\n"
  exit 0
fi

printf "${green}Tasks found:\\n"
printf "${no_color}\\n"

echo "$response" | jq -r '.tasks[] | "ID: \(.id)\nName: \(.name)\nStatus: \(.status.status)\nAssignees: \(.assignees | map(.username) | join(", "))\nURL: \(.url)\n---"'

exit 0