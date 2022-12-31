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

# Update Variables #
update_variables() {
  BIGGER_CONSOLE="$PTERO/resources/scripts/components/server/StatGraphs.tsx"
  CONFIG_FILE="$PTERO/config/app.php"
  PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
}

# Download Files #
download_files() {
  print "Downloading files..."

  mkdir -p $PTERO/temp
  curl -sSLo $PTERO/temp/AnimatedGraphics.tar.gz https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/AnimatedGraphics/AnimatedGraphics.tar.gz
  tar -xzvf $PTERO/temp/AnimatedGraphics.tar.gz -C $PTERO/temp
  cp -rf -- $PTERO/temp/AnimatedGraphics/* $PTERO
  rm -rf $PTERO/temp
}

# Check if another conflicting addon is installed #
check_conflict() {
  print "Checking if a similar/conflicting addon is already installed..."

  sleep 2
  if grep -q "Installed by Auto-Addons" "$BIGGER_CONSOLE"; then
    print_warning "The theme ${YELLOW}Bigger Console${RESET} is already installed, aborting..."
    exit 1
  fi
}

# Panel Production #
production() {
  print "Producing panel..."
  print_warning "This process takes a few minutes, please do not cancel it."

  if [ -d "$PTERO/node_modules" ]; then
    yarn --cwd $PTERO build:production
  else
    npm i -g yarn
    yarn --cwd $PTERO install
    yarn --cwd $PTERO build:production
  fi
}

bye() {
  print_brake 50
  echo
  echo -e "${GREEN}* The theme ${YELLOW}Animated Graphics${GREEN} was successfully installed."
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
  check_conflict
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
    echo "$MANUAL_DIR" >>"$INFORMATIONS/custom_directory.txt"
    update_variables
    compatibility
    check_conflict
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
