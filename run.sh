#!/bin/sh

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

# Get the directory where this script is located
script_dir="$(dirname "$0")"

# Set up logging rules
dbus='quickshell.dbus.properties.warning = false;quickshell.dbus.dbusmenu.warning = false'  # System tray dbus property errors
notifs='quickshell.service.notifications.warning = false'  # Notification server warnings on reload
sni='quickshell.service.sni.host.warning = false'  # StatusNotifierItem warnings on reload
process='QProcess: Destroyed while process'  # Long running processes on reload
cache="Cannot open: file://${XDG_CACHE_HOME:-$HOME/.cache}/nekroshell/imagecache/"

# Run quickshell with logging rules and filtering
qs -p "$script_dir" --log-rules "$dbus;$notifs;$sni" | grep -vF -e "$process" -e "$cache"
