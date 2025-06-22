#!/bin/bash

# declare colors
red='\033[0;31m'
default='\033[0m'

BASHRC="$HOME/.bashrc"

_register_scripts_autocomplete() {
  rsync -a scripts-autocomplete /etc/bash_completion.d/

  local AUTOCOMPLETE_SCRIPT="/etc/bash_completion.d/scripts-autocomplete"

  # Check if the sourcing line already exists in ~/.bashrc
  if [ ! -f "$BASHRC" ] || ! grep -q "$AUTOCOMPLETE_SCRIPT" "$BASHRC"; then
    echo "if [ -f $AUTOCOMPLETE_SCRIPT ]; then" >> "$BASHRC"
    echo "  source $AUTOCOMPLETE_SCRIPT" >> "$BASHRC"
    echo "fi # Added by scripts installer" >> "$BASHRC"
  fi
}

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
  --exclude="scripts" \
  --exclude="scripts-autocomplete"
printf "%b" "$msg_success"

printf "Registering keyword       "
rsync -a scripts $usr_local/bin
_register_scripts_autocomplete
printf "%b" "$msg_success"

printf "Setting permissions       "
find $usr_local/lib/scripts -type f -name "*.sh" -exec chmod +x {} \;
chmod +x $usr_local/bin/scripts
chmod +x /etc/bash_completion.d/scripts-autocomplete
chmod +x $usr_local/lib/scripts/uninstall.sh
chmod +x $usr_local/lib/scripts/update.sh
printf "%b" "$msg_success"

source "$BASHRC"

exit 0