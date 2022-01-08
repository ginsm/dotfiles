# Rudimentary battery monitor; either add this to your crontab or create
# a systemd service to run this at an interval you'd like

# Configuration
notif_time=3500

# Set environmental variables
export DISPLAY=":0"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

# Resolve percentage
percent="$(cat /sys/class/power_supply/BAT0/capacity)"

if [ "5" -ge "$percent" ]; then
    notify-send --expire-time=$notif_time -u critical "Low Battery" "Your battery is below 5% ($percent%)."
elif [ "15" -ge "$percent" ]; then
    notify-send --expire-time=$notif_time "Low Battery" "Your battery is below 15% ($percent%)."
fi