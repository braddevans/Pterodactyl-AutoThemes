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

# Download Files #
download_files() {
  print "Downloading files..."

  mkdir -p $PTERO/temp
  curl -sSLo $PTERO/temp/FlancoTheme.tar.gz https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/FlancoTheme/FlancoTheme.tar.gz
  tar -xzvf $PTERO/temp/FlancoTheme.tar.gz -C $PTERO/temp
  cp -rf -- $PTERO/temp/FlancoTheme/* $PTERO
  rm -rf $PTERO/temp
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
  echo -e "${GREEN}* The theme ${YELLOW}Flanco Theme${GREEN} was successfully installed."
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
  dependencies
  backup
  download_files
  production
  bye
elif [ "$PTERO_INSTALL" == false ]; then
  print_warning "The installation of your panel could not be located."
  echo -e "* ${GREEN}EXAMPLE${RESET}: ${YELLOW}/var/www/mypanel${RESET}"
  echo -ne "* Enter the pterodactyl installation directory manually: "
  read -r MANUAL_DIR
  if [ -d "$MANUAL_DIR" ]; then
    print "Directory has been found!"
    PTERO="$MANUAL_DIR"
    update_variables
    compatibility
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
