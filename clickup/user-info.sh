#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'
green='\033[0;32m'

# Validate CU_PERSONAL_TOKEN
if [ "$CU_PERSONAL_TOKEN" = "" ]; then
  printf "${red}Error: CU_PERSONAL_TOKEN should not be empty.\\n"
  printf "${no_color}\\n"
  printf "You can set CU_PERSONAL_TOKEN using \"export CU_PERSONAL_TOKEN=<VALUE>\"\\n"
  exit 2
fi

# Get user info
response=$(
  curl -s -X GET \
    "https://api.clickup.com/api/v2/user" \
    -H "Authorization: $CU_PERSONAL_TOKEN"
)

# Validate response
if echo "$response" | grep -q "</html>"; then
  printf "${red}Failed to get user info.\\n"
  printf "${no_color}\\n"
  exit 2
fi

# Check if response contains error
if echo "$response" | jq -e '.err' > /dev/null 2>&1; then
  error_msg=$(echo "$response" | jq -r '.err')
  printf "${red}Error: $error_msg\\n"
  printf "${no_color}\\n"
  exit 2
fi

printf "${green}Your ClickUp user info:\\n"
printf "${no_color}\\n"

echo "$response" | jq -r '.user | "ID: \(.id)\nUsername: \(.username)\nEmail: \(.email)\nColor: \(.color)"'

exit 0