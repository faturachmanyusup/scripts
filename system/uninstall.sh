#!/bin/bash

# declare colors
red='\033[0;31m'
green='\033[0;32m'
default='\033[0m'

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Uninstallation must be run as root.${default}\n"
  printf "hint: sudo scripts system uninstall\n"
  exit 1
fi

# Define paths
USR_LOCAL_LIB="/usr/local/lib/scripts"
USR_LOCAL_BIN="/usr/local/bin/scripts"
AUTOCOMPLETE_SCRIPT="/etc/bash_completion.d/scripts-autocomplete"
BASHRC="$HOME/.bashrc"

# Parse flags
KEEP_CONFIG=false

for arg in "$@"; do
  case $arg in
    --keep-config)
      KEEP_CONFIG=true
      shift
      ;;
  esac
done

# Function to remove autocomplete entries from .bashrc
remove_bashrc_entries() {
  if [ -f "$BASHRC" ]; then
    # Create a temporary file
    TEMP_FILE=$(mktemp)
    
    # Filter out the lines related to scripts-autocomplete
    grep -v "if \[ -f $AUTOCOMPLETE_SCRIPT \]; then" "$BASHRC" | \
    grep -v "  source $AUTOCOMPLETE_SCRIPT" | \
    grep -v "fi" > "$TEMP_FILE"
    
    # Replace the original file with the filtered content
    mv "$TEMP_FILE" "$BASHRC"
    
    printf "${green}Removed autocomplete entries from $BASHRC${default}\n"
  fi
}

# Start uninstallation
printf "Starting uninstallation of scripts collection...\n"

# Remove scripts from /usr/local/lib
if [ -d "$USR_LOCAL_LIB" ]; then
  rm -rf "$USR_LOCAL_LIB"
  printf "${green}Removed scripts from $USR_LOCAL_LIB${default}\n"
else
  printf "${red}Scripts directory not found at $USR_LOCAL_LIB${default}\n"
fi

# Remove scripts command from /usr/local/bin
if [ -f "$USR_LOCAL_BIN" ]; then
  rm -f "$USR_LOCAL_BIN"
  printf "${green}Removed scripts command from $USR_LOCAL_BIN${default}\n"
else
  printf "${red}Scripts command not found at $USR_LOCAL_BIN${default}\n"
fi

# Remove autocomplete script
if [ -f "$AUTOCOMPLETE_SCRIPT" ]; then
  rm -f "$AUTOCOMPLETE_SCRIPT"
  printf "${green}Removed autocomplete script from $AUTOCOMPLETE_SCRIPT${default}\n"
else
  printf "${red}Autocomplete script not found at $AUTOCOMPLETE_SCRIPT${default}\n"
fi

# Remove entries from .bashrc unless --keep-config flag is set
if [ "$KEEP_CONFIG" = false ]; then
  remove_bashrc_entries
else
  printf "${green}Keeping configuration in $BASHRC as requested${default}\n"
fi

printf "${green}Uninstallation completed successfully!${default}\n"
exit 0