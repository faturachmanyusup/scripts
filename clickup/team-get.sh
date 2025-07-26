#!/bin/bash

red='\033[0;31m'
no_color='\033[0m'
green='\033[0;32m'

# Parse command line arguments
email_filter=""
name_search=""
columns="id,name,email,status"

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--email)
      email_filter="$2"
      shift 2
      ;;
    -s|--search)
      name_search="$2"
      shift 2
      ;;
    --columns|-c)
      columns="$2"
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

# Get teams
response=$(
  curl -s -X GET \
    "https://api.clickup.com/api/v2/team" \
    -H "Authorization: $CU_PERSONAL_TOKEN"
)

# Validate response
if echo "$response" | grep -q "</html>"; then
  printf "${red}Failed to get teams.\\n"
  printf "${no_color}\\n"
  exit 2
fi

printf "${green}Teams and Members:\\n"
printf "${no_color}\\n"

# Parse columns to show (for members)
IFS=',' read -ra COLS <<< "$columns"

# Build header and format strings based on selected columns
header=""
format=""
separator=""
for col in "${COLS[@]}"; do
  case $col in
    id)
      header="$header%-15s "
      format="$format%-15s "
      separator="$separator%-15s "
      ;;
    name)
      header="$header%-30s "
      format="$format%-30s "
      separator="$separator%-30s "
      ;;
    email)
      header="$header%-40s "
      format="$format%-40s "
      separator="$separator%-40s "
      ;;
    status)
      header="$header%-10s "
      format="$format%-10s "
      separator="$separator%-10s "
      ;;
  esac
done

# Process each team separately
if [ "$email_filter" != "" ]; then
  teams=$(echo "$response" | jq -r --arg email "$email_filter" '.teams[] | select(.members[]?.user.email == $email) | [.id, .name] | @tsv')
else
  teams=$(echo "$response" | jq -r '.teams[] | [.id, .name] | @tsv')
fi

echo "$teams" | while IFS=$'\t' read -r team_id team_name; do
  printf "\\nID: %s\\n" "$team_id"
  printf "Name: %s\\n\\n" "$team_name"
  
  # Get members for this specific team
  if [ "$email_filter" != "" ]; then
    members=$(echo "$response" | jq -r --arg team_id "$team_id" --arg email "$email_filter" '.teams[] | select((.id | tostring) == $team_id) | .members[]? | select(.user.email == $email) | [(.user.id | tostring), (.user.username // "N/A"), (.user.email // "N/A"), "active"] | @tsv')
  else
    members=$(echo "$response" | jq -r --arg team_id "$team_id" '.teams[] | select((.id | tostring) == $team_id) | .members[]? | [(.user.id | tostring), (.user.username // "N/A"), (.user.email // "N/A"), "active"] | @tsv')
  fi
  
  # Apply name search filter if provided
  if [ "$name_search" != "" ]; then
    members=$(echo "$members" | grep -i "$name_search")
  fi
  
  # Check if there are members to display
  if [ -n "$members" ]; then
    # Print table header for this team
    printf "$header\\n" $(for col in "${COLS[@]}"; do echo "${col^^}"; done)
    printf "$separator\\n" $(for col in "${COLS[@]}"; do printf "%*s" ${#col} | tr ' ' '-'; echo; done)
    
    # Sort and display members for this team
    echo "$members" | sort -f -k2 | while IFS=$'\t' read -r id name email_addr status; do
      values=()
      for col in "${COLS[@]}"; do
        case $col in
          id) values+=("$id") ;;
          name) values+=("$name") ;;
          email) values+=("$email_addr") ;;
          status) values+=("$status") ;;
        esac
      done
      printf "$format\\n" "${values[@]}"
    done
  else
    printf "No members found.\\n"
  fi
done

exit 0