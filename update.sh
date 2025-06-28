#!/bin/bash

# declare colors
red='\033[0;31m'
default='\033[0m'
green='\033[0;32m'

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Update must be run as root.${default}\n"
  printf "hint: sudo scripts update\n"
  exit 1
fi

# Define temporary directory and source URL
TMP_DIR="/tmp/scripts"
SOURCE_URL="https://github.com/faturachmanyusup/scripts/archive/refs/heads/main.zip"
ZIP_FILE="$TMP_DIR/scripts.zip"

msg_success="✔\n"

printf "Creating temporary directory   "
# Create temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"
printf "%b" "$msg_success"

printf "Downloading latest version     "
# Download the latest version
curl -s -L "$SOURCE_URL" -o "$ZIP_FILE"
printf "%b" "$msg_success"

printf "Extracting files              "
# Extract the downloaded zip file
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
printf "%b" "$msg_success"

# Navigate to the extracted directory
cd "$TMP_DIR/scripts-main"

printf "Uninstalling current version  "
# Uninstall the current version
bash -i ./uninstall.sh > /dev/null
printf "%b" "$msg_success"

printf "Installing new version        "
# Install the latest version
bash -i ./install.sh > /dev/null
printf "%b" "$msg_success"

printf "Cleaning up                   "
# Clean up the temporary directory
rm -rf "$TMP_DIR"
printf "%b" "$msg_success"

printf "${green}Scripts have been successfully updated to the latest version.${default}\n"

exit 0