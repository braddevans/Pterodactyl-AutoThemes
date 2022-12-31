#!/bin/bash
# shellcheck source=/dev/null

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

# Update zing Variables #
update_zing_variables() {
  ZING="$PTERO/resources/scripts/components/SidePanel.tsx"
  CONFIG_FILE="$PTERO/config/app.php"
  PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
}


# Download Files #
download_files() {
  print "Downloading files..."

  mkdir -p $PTERO/temp
  curl -sSLo $PTERO/temp/ZingTheme.tar.gz https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/ZingTheme/ZingTheme.tar.gz
  tar -xzvf $PTERO/temp/ZingTheme.tar.gz -C $PTERO/temp
  cp -rf -- $PTERO/temp/ZingTheme/* $PTERO
  rm -rf $PTERO/temp
}

# Check if it is already installed #
verify_installation() {
  if [ -f "$ZING" ]; then
    print_error "This theme is already installed in your panel, aborting..."
    exit 1
  else
    dependencies
    backup
    download_files
    production
    bye
  fi
}

# Panel Production #
production() {
  print "Producing panel..."
  print_warning "This process takes a few minutes, please do not cancel it."

  if [ -d "$PTERO/node_modules" ]; then
    yarn --cwd $PTERO add @emotion/react
    yarn --cwd $PTERO build:production
  else
    npm i -g yarn
    yarn --cwd $PTERO install
    yarn --cwd $PTERO add @emotion/react
    yarn --cwd $PTERO build:production
  fi
}

bye() {
  print_brake 50
  echo
  echo -e "${GREEN}* The theme ${YELLOW}Zing Theme${GREEN} was successfully installed."
  echo -e "* A security backup of your panel has been created."
  echo -e "* Thank you for using this script."
  echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${RESET}"
  echo
  print_brake 50
}

# Exec Script #
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
  print "Installation of the panel found, continuing the installation..."

  compatibility
  verify_installation
elif [ "$PTERO_INSTALL" == false ]; then
  print_warning "The installation of your panel could not be located."
  echo -e "* ${GREEN}EXAMPLE${RESET}: ${YELLOW}/var/www/mypanel${RESET}"
  echo -ne "* Enter the pterodactyl installation directory manually: "
  read -r MANUAL_DIR
  if [ -d "$MANUAL_DIR" ]; then
    print "Directory has been found!"
    PTERO="$MANUAL_DIR"
    echo "$MANUAL_DIR" >>"$INFORMATIONS/custom_directory.txt"
    update_zing_variables
    compatibility
    verify_installation
    dependencies
    backup
    download_files
    production
    bye
  else
    print_error "The directory you entered does not exist."
    find_pterodactyl
  fi
fi
