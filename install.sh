msg_success="✔\\n"

printf "Installing dependencies   "
apt-get update -qq
apt-get install -qq rsync curl unzip jq -y > /dev/null
printf $msg_success

printf "Building sources          "
rsync -r \
  . /lib/scripts \
  --exclude .git \
  --exclude *.png \
  --exclude README.md \
  --exclude install.sh \
  --exclude scripts
printf $msg_success

printf "Registering keyword       "
rsync scripts /bin
printf $msg_success

printf "Setting permissions       "
chmod -R +x /lib/scripts
chmod +x /bin/scripts
printf $msg_success
