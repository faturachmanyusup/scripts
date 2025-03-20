#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'

task_ids=($TARGET_TASKS)
status=$STATUS

# Validate CU_PERSONAL_TOKEN
if [ "$CU_PERSONAL_TOKEN" = "" ]
then
  printf "${red}Error: CU_PERSONAL_TOKEN should not be empty.\\n"
  printf "${no_color}\\n"
  printf "You can set CU_PERSONAL_TOKEN using "'"export CU_PERSONAL_TOKEN=<VALUE>"'"\\n"

  exit 2
fi

# Validate TASK IDs
if [ "$task_ids" = "" ]
then
  printf "${red}Error: TARGET_TASKS should not be empty.\\n"
  printf "${no_color}\\n"
  printf "You can set TARGET_TASKS using "'"export TARGET_TASKS=<VALUE>"'"\\n"

  exit 2
fi

#Validate status
if [ "$status" = "" ]
then
  printf "${red}Error: STATUS should not be empty.\\n"
  printf "${no_color}\\n"
  printf "You can set STATUS using "'"export STATUS=<VALUE>"'"\\n"

  exit 2
fi

# Loop for Task IDs
for i in "${task_ids[@]}"
do
  # Make HTTP Request for updating status
	response=$(
    curl -s -X PUT \
      "https://api.clickup.com/api/v2/task/$i" \
      -H "Authorization: $CU_PERSONAL_TOKEN" \
      -d "status=$status"
  )

  # Get last line of response
  last_line_res=$(tail -q -n1 <<< "$response")

  # Validate response. If response is HTML, it means error.
  if [ "$last_line_res" = "</html>" ]
  then
    printf "${red}Failed to update task with ID $i.\\n"
    printf "${no_color}\\n"
    printf "Note: Task ID should not include #\\n"

    exit 2
  fi

  # Get variables
  id=$(echo "$response" | jq -r '.id')
  name=$(echo "$response" | jq -r '.name')
  url=$(echo "$response" | jq -r '.url')
  parent_id=$(echo "$response" | jq -r '.parent')
  parent_url=""

  # Reassign parent_url if parent_id exists.
  if [ "$parent_id" != "null" ]
  then
    parent_url="https://app.clickup.com/t/$parent_id"
  fi

  # Print some informations
  printf "Status has been updated to $status for:\\n"
  printf "$name #$id\\n"
  printf "\\n"
  printf "Parent url: $parent_url\\n"
  printf "Task url: $url\\n"
done

exit 0