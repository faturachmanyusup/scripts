#!/bin/bash

# declare colors
red='\033[0;31m'
default='\033[0m'
green='\033[0;32m'

BASHRC="$HOME/.bashrc"
AUTOCOMPLETE_SCRIPT="/etc/bash_completion.d/scripts-autocomplete"

_remove_autocomplete_from_bashrc() {
  # Remove the autocomplete sourcing lines from .bashrc if they exist
  if [ -f "$BASHRC" ]; then
    # Create a temporary file
    local TEMP_FILE=$(mktemp)
    
    # Filter out the lines that source the autocomplete script
    grep -v "if \[ -f $AUTOCOMPLETE_SCRIPT \]; then" "$BASHRC" | \
    grep -v "  source $AUTOCOMPLETE_SCRIPT" | \
    grep -v "fi # Added by scripts installer" > "$TEMP_FILE"
    
    # Replace the original .bashrc with our filtered version
    mv "$TEMP_FILE" "$BASHRC"
  fi
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Uninstallation must be run as root.${default}\n"
  printf "hint: sudo ./uninstall.sh\n"
  exit 1
fi

# Parse command line arguments
VERBOSE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

msg_success="✔\n"

# Function to print verbose messages
print_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo -e "$1"
  fi
}

printf "Removing scripts from system   "
# Remove the main scripts directory
if [ -d "/usr/local/lib/scripts" ]; then
  rm -rf /usr/local/lib/scripts
  print_verbose "- Removed /usr/local/lib/scripts"
fi

# Remove the main command
if [ -f "/usr/local/bin/scripts" ]; then
  rm -f /usr/local/bin/scripts
  print_verbose "- Removed /usr/local/bin/scripts"
fi

# Remove the autocomplete script
if [ -f "$AUTOCOMPLETE_SCRIPT" ]; then
  rm -f "$AUTOCOMPLETE_SCRIPT"
  print_verbose "- Removed $AUTOCOMPLETE_SCRIPT"
fi

# Remove the autocomplete entries from .bashrc
_remove_autocomplete_from_bashrc
print_verbose "- Cleaned up $BASHRC"

printf "%b" "$msg_success"

printf "${green}Scripts have been successfully uninstalled from your system.${default}\n"

exit 0