#!/bin/bash

# declare colors
red='\033[0;31m'
default='\033[0m'

BASHRC="$HOME/.bashrc"
AUTOCOMPLETE_SCRIPT="/etc/bash_completion.d/scripts-autocomplete"

_remove_autocomplete_from_bashrc() {
  # Remove the autocomplete sourcing from ~/.bashrc if it exists
  if [ -f "$BASHRC" ] && grep -q "$AUTOCOMPLETE_SCRIPT" "$BASHRC"; then
    # Create a temporary file
    temp_file=$(mktemp)
    # Filter out the lines containing the autocomplete script
    grep -v "$AUTOCOMPLETE_SCRIPT" "$BASHRC" > "$temp_file"
    # Replace the original file with the filtered content
    mv "$temp_file" "$BASHRC"
  fi
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Uninstallation must be run as root.${default}\n"
  printf "hint: sudo ./uninstall.sh\n"
  exit 1
fi

msg_success="✔\n"
usr_local=/usr/local/

printf "Removing scripts from bin directory... "
rm -f $usr_local/bin/scripts
printf "%b" "$msg_success"

printf "Removing autocomplete script... "
rm -f $AUTOCOMPLETE_SCRIPT
printf "%b" "$msg_success"

printf "Removing scripts library... "
rm -rf $usr_local/lib/scripts
printf "%b" "$msg_success"

printf "Cleaning up bashrc... "
_remove_autocomplete_from_bashrc
printf "%b" "$msg_success"

printf "\n${default}Scripts have been successfully uninstalled.\n"

exit 0