#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'
green='\033[0;32m'

# Parse command line arguments
team_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--team)
      team_id="$2"
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

# Validate TEAM_ID
if [ "$team_id" = "" ]; then
  printf "${red}Error: Team ID is required.\\n"
  printf "${no_color}\\n"
  printf "Usage: space-list.sh -t <TEAM_ID>\\n"
  printf "Example: space-list.sh -t 123456789\\n"
  exit 2
fi

# Get spaces from team
response=$(
  curl -s -X GET \
    "https://api.clickup.com/api/v2/team/$team_id/space" \
    -H "Authorization: $CU_PERSONAL_TOKEN"
)

# Validate response
if echo "$response" | grep -q "</html>"; then
  printf "${red}Failed to get spaces.\\n"
  printf "${no_color}\\n"
  printf "Please check your TEAM_ID and CU_PERSONAL_TOKEN\\n"
  exit 2
fi

# Check if response contains error
if echo "$response" | jq -e '.err' > /dev/null 2>&1; then
  error_msg=$(echo "$response" | jq -r '.err')
  printf "${red}Error: $error_msg\\n"
  printf "${no_color}\\n"
  exit 2
fi

printf "${green}Spaces in team:\\n"
printf "${no_color}\\n"

echo "$response" | jq -r '.spaces[] | "ID: \(.id)\nName: \(.name)\n---"'

exit 0