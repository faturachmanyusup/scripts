#!/bin/bash

# declare colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
default='\033[0m'

# Paths
SCRIPTS_LIB="/usr/local/lib/scripts"
SCRIPTS_BIN="/usr/local/bin/scripts"
BASHRC="$HOME/.bashrc"
AUTOCOMPLETE_SCRIPT="/etc/bash_completion.d/scripts-autocomplete"

# Function to display usage information
usage() {
  echo "Usage: sudo ./uninstall.sh [OPTIONS]"
  echo
  echo "Options:"
  echo "  -h, --help     Display this help message"
  echo "  -y, --yes      Skip confirmation prompt"
  echo "  -v, --verbose  Show detailed output"
  echo
  exit 0
}

# Parse command line arguments
SKIP_CONFIRM=false
VERBOSE=false

for arg in "$@"; do
  case $arg in
    -h|--help)
      usage
      ;;
    -y|--yes)
      SKIP_CONFIRM=true
      ;;
    -v|--verbose)
      VERBOSE=true
      ;;
    *)
      echo "Unknown option: $arg"
      usage
      ;;
  esac
done

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Uninstallation must be run as root.${default}\n"
  printf "hint: sudo ./uninstall.sh\n"
  exit 1
fi

# Confirmation prompt (unless skipped)
if [ "$SKIP_CONFIRM" = false ]; then
  printf "${yellow}This will remove all scripts collection components:${default}\n"
  printf "  - Scripts from $SCRIPTS_LIB\n"
  printf "  - Command from $SCRIPTS_BIN\n"
  printf "  - Autocomplete from $AUTOCOMPLETE_SCRIPT\n"
  printf "  - Related entries from $BASHRC\n\n"
  
  read -p "Are you sure you want to uninstall? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    printf "Uninstallation cancelled.\n"
    exit 0
  fi
fi

# Success and error messages
msg_success="${green}✔${default}\n"
msg_error="${red}✗${default}\n"
msg_notfound="${yellow}Not found${default}\n"

# Track if any errors occurred
ERRORS=0

# Function to log verbose messages
log_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Remove scripts from /usr/local/lib/scripts
printf "Removing scripts from $SCRIPTS_LIB... "
if [ -d "$SCRIPTS_LIB" ]; then
  log_verbose "Deleting directory $SCRIPTS_LIB"
  if rm -rf "$SCRIPTS_LIB"; then
    printf "%b" "$msg_success"
  else
    printf "%b" "$msg_error"
    log_verbose "Failed to remove $SCRIPTS_LIB"
    ERRORS=$((ERRORS+1))
  fi
else
  printf "%b" "$msg_notfound"
  log_verbose "$SCRIPTS_LIB directory not found"
fi

# Remove scripts command from /usr/local/bin
printf "Removing scripts command from $SCRIPTS_BIN... "
if [ -f "$SCRIPTS_BIN" ]; then
  log_verbose "Deleting file $SCRIPTS_BIN"
  if rm -f "$SCRIPTS_BIN"; then
    printf "%b" "$msg_success"
  else
    printf "%b" "$msg_error"
    log_verbose "Failed to remove $SCRIPTS_BIN"
    ERRORS=$((ERRORS+1))
  fi
else
  printf "%b" "$msg_notfound"
  log_verbose "$SCRIPTS_BIN file not found"
fi

# Remove autocomplete script
printf "Removing autocomplete script... "
if [ -f "$AUTOCOMPLETE_SCRIPT" ]; then
  log_verbose "Deleting file $AUTOCOMPLETE_SCRIPT"
  if rm -f "$AUTOCOMPLETE_SCRIPT"; then
    printf "%b" "$msg_success"
  else
    printf "%b" "$msg_error"
    log_verbose "Failed to remove $AUTOCOMPLETE_SCRIPT"
    ERRORS=$((ERRORS+1))
  fi
else
  printf "%b" "$msg_notfound"
  log_verbose "$AUTOCOMPLETE_SCRIPT file not found"
fi

# Remove autocomplete entries from ~/.bashrc
printf "Cleaning up .bashrc entries... "
if [ -f "$BASHRC" ]; then
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  log_verbose "Created temporary file $TEMP_FILE"
  
  # Use sed to remove the block of lines related to scripts-autocomplete
  # The pattern matches the if-then-fi block that sources the autocomplete script
  if sed "/if \[ -f $AUTOCOMPLETE_SCRIPT \]; then/,+2d" "$BASHRC" > "$TEMP_FILE"; then
    # Replace the original file with the filtered content
    if mv "$TEMP_FILE" "$BASHRC"; then
      printf "%b" "$msg_success"
    else
      printf "%b" "$msg_error"
      log_verbose "Failed to update $BASHRC"
      ERRORS=$((ERRORS+1))
    fi
  else
    printf "%b" "$msg_error"
    log_verbose "Failed to process $BASHRC"
    ERRORS=$((ERRORS+1))
    # Clean up temp file
    rm -f "$TEMP_FILE"
  fi
else
  printf "%b" "$msg_notfound"
  log_verbose "$BASHRC file not found"
fi

# Final status message
if [ $ERRORS -eq 0 ]; then
  printf "\n${green}Uninstallation completed successfully!${default}\n"
  printf "You may need to restart your shell or source your .bashrc file for changes to take effect.\n"
else
  printf "\n${yellow}Uninstallation completed with $ERRORS errors.${default}\n"
  printf "Some components may not have been fully removed.\n"
fi

exit $ERRORS