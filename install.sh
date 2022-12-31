#!/bin/bash

set -e

########################################################
#
#         Pterodactyl-AutoThemes Installation
#
#         Created and maintained by Ferks-FK
#
#            Protected by MIT License
#
########################################################

MAINTAINER_REPO="braddevans"

# import functions for the build.sh from github scripts/functions.sh
curl -sSLo /tmp/ptero_functions.sh https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/main/scripts/functions.sh
chmod +x /tmp/ptero_functions.sh
source /tmp/ptero_functions.sh

# Check Sudo #
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# Check Git #
if [ -z "$SCRIPT_VERSION" ]; then
  error "Could not get the version of the script using GitHub."
  echo "* Please check on the site below if the 'API Requests' are as normal status."
  echo -e "${YELLOW}$(hyperlink "$GITHUB_STATUS_URL")${RESET}"
  exit 1
fi

# Check Curl #
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

cancel() {
  echo
  echo -e "* ${RED}Installation Canceled!${RESET}"
  done=true
  exit 1
}

done=false

echo
print_brake 70
echo "* Pterodactyl-AutoThemes Script @ $SCRIPT_VERSION"
echo
echo "* Copyright (C) 2021 - $(date +%Y), Ferks-FK."
echo "* https://github.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes"
echo
echo "* This script is not associated with the official Pterodactyl Project."
print_brake 70
echo

Backup() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/backup.sh)
}

Dracula() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/Dracula/build.sh)
}

Enola() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/Enola/build.sh)
}

Twilight() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/Twilight/build.sh)
}

ZingTheme() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/ZingTheme/build.sh)
}

FlancoTheme() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/FlancoTheme/build.sh)
}

BackgroundVideo() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/BackgroundVideo/build.sh)
}

AnimatedGraphics() {
  bash <(curl -s https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/AnimatedGraphics/build.sh)
}

while [ "$done" == false ]; do
  options=(
    "Restore Panel Backup (Restore your panel if you have problems or want to remove themes)"
    "Install Dracula (Only 1.11.2+)"
    "Install Enola (Only 1.11.2+)"
    "Install Twilight (Only 1.11.2+)"
    "Install Zing Theme (Only 1.11.2+)"
    "Install Flanco Theme (Only 1.11.2+)"
    "Install Background Video (Only 1.11.2+)"
    "Install Animated Graphics (Only 1.11.2+)"

    \
    "Cancel Installation"
  )

  actions=(
    "Backup"
    "Dracula"
    "Enola"
    "Twilight"
    "ZingTheme"
    "FlancoTheme"
    "BackgroundVideo"
    "AnimatedGraphics"

    \
    "cancel"
  )

  echo "* Which theme do you want to install?"
  echo

  for i in "${!options[@]}"; do
    echo "[$i] ${options[$i]}"
  done

  echo
  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
