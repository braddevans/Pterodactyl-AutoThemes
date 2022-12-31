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
  CONFIG_FILE="$PTERO/config/app.php"
  PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
  VIDEO_FILE="$(cd "$PTERO/public" && find . -iname '*.mp4' | tail -1 | sed "s/.\///g")"
  ZING="$PTERO/resources/scripts/components/SidePanel.tsx"
}

# Download Files #
download_files() {
  print "Downloading files..."

  mkdir -p $PTERO/temp
  curl -sSLo $PTERO/temp/BackgroundVideo.tar.gz https://raw.githubusercontent.com/"${MAINTAINER_REPO}"/Pterodactyl-AutoThemes/"${SCRIPT_VERSION}"/themes/version-1.x/BackgroundVideo/BackgroundVideo.tar.gz
  tar -xzvf $PTERO/temp/BackgroundVideo.tar.gz -C $PTERO/temp
  cp -rf -- $PTERO/temp/BackgroundVideo/* $PTERO
  rm -rf $PTERO/temp
}

# Detect if the user has passed your video file in mp4 format #
detect_video() {
  echo
  echo -e "* Please open your FTP manager, and upload your video file to the background."
  echo -e "* Upload it to ${GREEN}${PTERO}/public${RESET}"
  echo
  print_warning "Your video can have any name, but must be in ${GREEN}.mp4${RESET} format."
  echo -n -e "* Once you successfully upload the video, press ${GREEN}ENTER${RESET} for the script to continue."
  read -r
  while [ -z "$VIDEO_FILE" ]; do
    update_variables
    echo
    print_warning "Unable to locate your video file, please check that it is in the correct directory."
    echo -e "* New check in 5 seconds..."
    sleep 5
    find . -iname '*.mp4' | tail -1 &>/dev/null
  done
  echo -n -e "* The file ${GREEN}$VIDEO_FILE${RESET} have been found, is that correct? (y/N): "
  read -r CHECK_VIDEO
  if [[ "$CHECK_VIDEO" =~ [Yy] ]]; then
    # Configure #
    sed -i "5a\import './user.css';" "$PTERO/resources/scripts/index.tsx"
    sed -i -e "s@<VIDEO_NAME>@$VIDEO_FILE@g" "$PTERO/resources/scripts/components/App.tsx"
  elif [[ "$CHECK_VIDEO" =~ [Nn] ]]; then
    rm -r "$PTERO/public/$VIDEO_FILE"
    VIDEO_FILE=""
    detect_video
  fi
}

# Write the informations to a file for a safety check of the backup script #
write_informations() {
  mkdir -p "$INFORMATIONS"
  # Write the filename to a file for the backup script to proceed later #
  echo "$VIDEO_FILE" >>"$INFORMATIONS/background.txt"
}

# Check if it is already installed #
verify_installation() {
  if grep '<video autoPlay muted loop className="video">' "$PTERO/resources/scripts/components/App.tsx" &>/dev/null; then
    print_error "This theme is already installed in your panel, aborting..."
    exit 1
  else
    dependencies
    backup
    download_files
    detect_video
    write_informations
    production
    bye
  fi
}

# Check if another conflicting addon is installed #
check_conflict() {
  print "Checking if a similar/conflicting addon is already installed..."

  sleep 2
  if [ -f "$PTERO/public/themes/pterodactyl/css/admin.css" ]; then
    echo -e "* ${RED}The theme ${YELLOW}Dracula, Enola or Twilight ${RED}is already installed, aborting...${RESET}"
    exit 1
  elif [ -f "$ZING" ]; then
    echo -e "* ${RED}The theme ${YELLOW}ZingTheme ${RED}is already installed, aborting...${RESET}"
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
  echo -e "${GREEN}* The theme ${YELLOW}Background Video${GREEN} was successfully installed."
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
    update_variables
    compatibility
    check_conflict
    verify_installation
  else
    print_error "The directory you entered does not exist."
    find_pterodactyl
  fi
fi
