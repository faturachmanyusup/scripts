#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'
green='\033[0;32m'

# Parse command line arguments
space_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--space)
      space_id="$2"
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

# Validate SPACE_ID
if [ "$space_id" = "" ]; then
  printf "${red}Error: Space ID is required.\\n"
  printf "${no_color}\\n"
  printf "Usage: list-get.sh -s <SPACE_ID>\\n"
  printf "Example: list-get.sh -s 123456789\\n"
  exit 2
fi

# Get lists from space
response=$(
  curl -s -X GET \
    "https://api.clickup.com/api/v2/space/$space_id/list" \
    -H "Authorization: $CU_PERSONAL_TOKEN"
)

# Validate response
if echo "$response" | grep -q "</html>"; then
  printf "${red}Failed to get lists.\\n"
  printf "${no_color}\\n"
  printf "Please check your SPACE_ID and CU_PERSONAL_TOKEN\\n"
  exit 2
fi

# Check if response contains error
if echo "$response" | jq -e '.err' > /dev/null 2>&1; then
  error_msg=$(echo "$response" | jq -r '.err')
  printf "${red}Error: $error_msg\\n"
  printf "${no_color}\\n"
  exit 2
fi

printf "${green}Lists in space:\\n"
printf "${no_color}\\n"

echo "$response" | jq -r '.lists[] | "ID: \(.id)\nName: \(.name)\nTask Count: \(.task_count)\n---"'

exit 0