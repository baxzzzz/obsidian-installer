#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OBSIDIAN_FILENAME=${SCRIPT_DIR}/Obsidian.AppImage
ICON_FILENAME=${SCRIPT_DIR}/obsidian.png

check_root_access()
{
  if [ "$EUID" -ne 0 ]; then
    echo "Operation aborted, please execute the script as root or with the sudo command."
    exit 1
  fi
}

download_obsidian()
{
  echo "Download Obsidian AppImage file."

  local url=$( curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest  \
    | grep "browser_download_url.*AppImage" | tail -n 1 | cut -d '"' -f 4 )

  if [[ -z "$url" ]]; then
    echo "Missing Obsidian download link."
    exit 2
  fi

  curl --location --output "${OBSIDIAN_FILENAME}" "$url"
}

download_obsidian_icon()
{
  echo "Download Obsidian Icon file."
  local url="https://cdn.discordapp.com/icons/686053708261228577/1361e62fed2fee55c7885103c864e2a8.png"
  curl --location --output "${ICON_FILENAME}" "$url"
}

install_obsidian()
{
  echo "Install Obsidian."
  mkdir --parents /opt/obsidian/
  mv Obsidian.AppImage /opt/obsidian
  chmod +x /opt/obsidian/Obsidian.AppImage
  mv obsidian.png /opt/obsidian
  ln -sf /opt/obsidian/obsidian.png /usr/share/pixmaps
}

create_desktop_file()
{
  echo "Create desktop Obsidian file."

  echo "[Desktop Entry]
  Type=Application
  Name=Obsidian
  Exec=/opt/obsidian/Obsidian.AppImage
  Icon=obsidian
  Terminal=false" > /usr/share/applications/obsidian.desktop

  update-desktop-database /usr/share/applications
}

main()
{
  check_root_access
  download_obsidian
  download_obsidian_icon
  install_obsidian
  create_desktop_file
}

main