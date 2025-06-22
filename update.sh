#!/bin/bash

# declare colors
red='\033[0;31m'
green='\033[0;32m'
default='\033[0m'

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Update must be run as root.${default}\n"
  printf "hint: sudo scripts update\n"
  exit 1
fi

# Define temporary directory and source URL
TEMP_DIR="/tmp/scripts"
SOURCE_URL="https://github.com/faturachmanyusup/scripts/archive/refs/heads/main.zip"
DOWNLOAD_FILE="$TEMP_DIR/scripts.zip"

msg_success="✔\n"

printf "Creating temporary directory   "
# Create temporary directory and clean it if it already exists
if [ -d "$TEMP_DIR" ]; then
  rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"
printf "%b" "$msg_success"

printf "Downloading latest version     "
# Download the latest version
curl -s -L "$SOURCE_URL" -o "$DOWNLOAD_FILE"
if [ $? -ne 0 ]; then
  printf "${red}Error: Failed to download the latest version.${default}\n"
  rm -rf "$TEMP_DIR"
  exit 1
fi
printf "%b" "$msg_success"

printf "Extracting files              "
# Extract the downloaded zip file
unzip -q "$DOWNLOAD_FILE" -d "$TEMP_DIR"
if [ $? -ne 0 ]; then
  printf "${red}Error: Failed to extract the downloaded file.${default}\n"
  rm -rf "$TEMP_DIR"
  exit 1
fi
printf "%b" "$msg_success"

# Find the extracted directory (should be scripts-main)
EXTRACTED_DIR=$(find "$TEMP_DIR" -type d -name "scripts-*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
  printf "${red}Error: Could not find extracted directory.${default}\n"
  rm -rf "$TEMP_DIR"
  exit 1
fi

printf "Uninstalling old version      "
# Uninstall the current version
bash -i /usr/local/lib/scripts/uninstall.sh
printf "%b" "$msg_success"

printf "Installing new version        "
# Install the new version
cd "$EXTRACTED_DIR" && bash -i ./install.sh
if [ $? -ne 0 ]; then
  printf "${red}Error: Failed to install the new version.${default}\n"
  rm -rf "$TEMP_DIR"
  exit 1
fi
printf "%b" "$msg_success"

printf "Cleaning up                   "
# Clean up the temporary directory
rm -rf "$TEMP_DIR"
printf "%b" "$msg_success"

printf "${green}Scripts have been successfully updated to the latest version.${default}\n"

exit 0