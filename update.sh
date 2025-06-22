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

# Create temporary directory
TMP_DIR="/tmp/scripts"
DOWNLOAD_URL="https://github.com/faturachmanyusup/scripts/archive/refs/heads/main.zip"
ZIP_FILE="$TMP_DIR/scripts.zip"

# Create temp directory if it doesn't exist
printf "Creating temporary directory... "
mkdir -p "$TMP_DIR"
printf "✔\n"

# Download the latest version
printf "Downloading latest version... "
curl -s -L "$DOWNLOAD_URL" -o "$ZIP_FILE"
if [ $? -ne 0 ]; then
  printf "${red}Failed to download the latest version.${default}\n"
  rm -rf "$TMP_DIR"
  exit 1
fi
printf "✔\n"

# Unzip the downloaded file
printf "Extracting files... "
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
if [ $? -ne 0 ]; then
  printf "${red}Failed to extract files.${default}\n"
  rm -rf "$TMP_DIR"
  exit 1
fi
printf "✔\n"

# Navigate to the extracted directory
cd "$TMP_DIR/scripts-main" || {
  printf "${red}Failed to navigate to extracted directory.${default}\n"
  rm -rf "$TMP_DIR"
  exit 1
}

# Uninstall current version
printf "Uninstalling current version... "
scripts uninstall
printf "✔\n"

# Install new version
printf "Installing new version... "
./install.sh
if [ $? -ne 0 ]; then
  printf "${red}Failed to install new version.${default}\n"
  rm -rf "$TMP_DIR"
  exit 1
fi
printf "✔\n"

# Clean up
printf "Cleaning up... "
rm -rf "$TMP_DIR"
printf "✔\n"

printf "${green}Scripts have been successfully updated to the latest version.${default}\n"

exit 0