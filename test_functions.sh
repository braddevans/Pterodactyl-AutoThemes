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

test() {
  print_brake 50
  echo
  echo -e "${GREEN}* ${YELLOW}OS: ${OS}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}os_ver: ${OS_VER}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}os_ver_major: ${OS_VER_MAJOR}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}ptero_install: ${PTERO_INSTALL}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}ptero_version: ${PANEL_VERSION}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}ptero_dir: ${PTERO}${GREEN}."
  echo -e "${GREEN}* ${YELLOW}ptero_compatible: ${IS_COMPATIBLE_VERSION}${GREEN}."
  echo -e "* Discord Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${RESET}"
  echo
  print_brake 50
}

# Exec Script #
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
  print "Panel found, continuing test..."
  compatibility
  test
fi
