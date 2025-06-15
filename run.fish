#!/usr/bin/env fish

# Initialize nekroshell configuration directories and files
set -l config_dir ~/.local/state/nekroshell
set -l wallpaper_dir $config_dir/wallpaper
set -l scheme_file $config_dir/scheme.json
set -l wallpaper_path_file $wallpaper_dir/path.txt

if not test -d $config_dir
    echo "Creating nekroshell configuration directory..."
    mkdir -p $wallpaper_dir
end

if not test -f $scheme_file
    echo "Creating default color scheme file..."
    echo '{"mode": "dark", "colours": {}}' > $scheme_file
end

if not test -f $wallpaper_path_file
    echo "Creating wallpaper path file..."
    echo "" > $wallpaper_path_file
end

set -l dbus 'quickshell.dbus.properties.warning = false;quickshell.dbus.dbusmenu.warning = false'  # System tray dbus property errors
set -l notifs 'quickshell.service.notifications.warning = false'  # Notification server warnings on reload
set -l sni 'quickshell.service.sni.host.warning = false'  # StatusNotifierItem warnings on reload
set -l process 'QProcess: Destroyed while process'  # Long running processes on reload
set -l cache "Cannot open: file://$XDG_CACHE_HOME/nekroshell/imagecache/"

qs -p (dirname (status filename)) --log-rules "$dbus;$notifs;$sni" | grep -vF -e $process -e $cache
