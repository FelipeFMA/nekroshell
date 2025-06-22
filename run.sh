#!/bin/sh

if [ "$1" != "--ignore" ]; then
    # Check for Arch Linux
    if [ ! -f /etc/os-release ] || ! grep -q '^ID=arch' /etc/os-release; then
        echo "Error: This script is intended for Arch Linux."
        echo "Use --ignore to run anyway."
        exit 1
    fi

    # Check for Hyprland
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo "Error: This script is intended to be run inside a Hyprland session."
        echo "Use --ignore to run anyway."
        exit 1
    fi

    # Check for necessary packages
    packages="quickshell networkmanager bluez bluez-utils apple-fonts ttf-material-symbols-variable-git"
    missing_packages=""

    for pkg in $packages; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing_packages="$missing_packages $pkg"
        fi
    done

    if [ -n "$missing_packages" ]; then
        echo "Error: The following packages are not installed:"
        echo "$missing_packages"
        echo "Please install them using an AUR helper. If you know what you are doing, use --ignore to run anyway."
        exit 1
    fi
fi

pkill -f quickshell
sleep 0.2

# Initialize nekroshell configuration directories and files
config_dir="$HOME/.local/state/nekroshell"
wallpaper_dir="$config_dir/wallpaper"
scheme_file="$config_dir/scheme.json"
wallpaper_path_file="$wallpaper_dir/path.txt"

if [ ! -d "$config_dir" ]; then
    echo "Creating nekroshell configuration directory..."
    mkdir -p "$wallpaper_dir"
fi

if [ ! -f "$scheme_file" ]; then
    echo "Creating default color scheme file..."
    echo '{"mode": "dark", "colours": {}}' > "$scheme_file"
fi

if [ ! -f "$wallpaper_path_file" ]; then
    echo "Creating wallpaper path file..."
    echo "" > "$wallpaper_path_file"
fi

# System tray dbus property errors
dbus='quickshell.dbus.properties.warning = false;quickshell.dbus.dbusmenu.warning = false'
# Notification server warnings on reload
notifs='quickshell.service.notifications.warning = false'
# StatusNotifierItem warnings on reload
sni='quickshell.service.sni.host.warning = false'
# Long running processes on reload
process='QProcess: Destroyed while process'
# Cache warnings
cache="Cannot open: file://${XDG_CACHE_HOME:-$HOME/.cache}/nekroshell/imagecache/"

# Get the directory of the current script
script_dir="$(dirname "$0")"

export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"

qs -p "$script_dir" --log-rules "$dbus;$notifs;$sni" | grep -vF -e "$process" -e "$cache"
