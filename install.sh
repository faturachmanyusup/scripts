#!/bin/bash

# declare colors
red='\033[0;31m'
default='\033[0m'

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "${red}Error: Installation must be run as root.${default}\\n"
  printf "hint: sudo ./install.sh\\n"

  exit 1
fi

msg_success="✔\\n"
usr_local=/usr/local/

printf "Installing dependencies   "
apt-get update -qq
apt-get install -qq rsync curl jq -y > /dev/null
printf "%b" "$msg_success"

printf "Building resources        "
mkdir -p $usr_local/lib/scripts  # Ensure the directory exists
rsync -a . $usr_local/lib/scripts \
  --exclude=".git" \
  --exclude="*.png" \
  --exclude="README.md" \
  --exclude="install.sh" \
  --exclude="scripts"
printf "%b" "$msg_success"

printf "Registering keyword       "
rsync -a scripts $usr_local/bin
printf "%b" "$msg_success"

printf "Setting permissions       "
find $usr_local/lib/scripts -type f -name "*.sh" -exec chmod +x {} \;
chmod +x $usr_local/bin/scripts
printf "%b" "$msg_success"

exit 0