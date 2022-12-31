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


# Download twilight Files #
download_twilight_files() {
  print "Downloading files..."

  mkdir -p $PTERO/temp
  curl -sSLo $PTERO/temp/Twilight.tar.gz https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/Twilight/Twilight.tar.gz
  tar -xzvf $PTERO/temp/Twilight.tar.gz -C $PTERO/temp
  cp -rf -- $PTERO/temp/Twilight/* $PTERO
  rm -rf $PTERO/temp
}

# Configure #
configure_twilight() {
  sed -i "5a\import './user.css';" "$PTERO/resources/scripts/index.tsx"
  sed -i "32a\{!! Theme::css('css/admin.css?t={cache-version}') !!}" "$PTERO/resources/views/layouts/admin.blade.php"
}


bye() {
  print_brake 50
  echo
  echo -e "${GREEN}* The theme ${YELLOW}Twilight${GREEN} was successfully installed."
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
  download_twilight_files
  configure_twilight
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
    dependencies
    backup
    download_twilight_files
    configure_twilight
    production
    bye
  else
    print_error "The directory you entered does not exist."
    find_pterodactyl
  fi
fi
