#!/bin/bash

module_path="$HOME/.config/polybar/mod/bluetoothctl"

get_devices() {
  echo -e "$(echo "devices" | bluetoothctl | awk 'FNR > 4 {print last} {last=$0}')"
}

device_connected() {
  device_id="$1"
  connected="$(echo "info $device_id" | bluetoothctl | grep -i connected | cut -d' ' -f2)"
  if [ "$connected" == "yes" ]; then echo -e "*"; else echo -e ""; fi
}

# Devices with a trailing '*' are already connected & will disconnect
# upon selection.
dmenu_selector() {
  bluetooth_devices="$(get_devices)"
  device_name=()

  # Looping helpers
  IFS=$'\n'
  index=0

  for device in $bluetooth_devices; do
    device_id=$(echo $device | cut -d' ' -f2)
    connected="$(device_connected $device_id)" # returns empty string or "*"
    device_name[$index]="$(echo $device | cut -d' ' -f3-)$connected"
    index=$(($index + 1))
  done

  choice="$(echo ${device_name[@]} | dmenu -h 36 -nb '#101215')"
  if [ "${choice: -1}" == "*" ]; then command="disconnect"; fi
  choice_id="$(echo $bluetooth_devices | grep $choice | awk '{print $2}')"

  echo "${command:-connect} $choice_id" | bluetoothctl
}


toggle_power() {
  powered="$(echo "show" | bluetoothctl | grep -i powered | cut -d' ' -f2)"
  if [ "$powered" == "yes" ]; then new_state="off"; else new_state="on"; fi
  echo "power $new_state" | bluetoothctl
}


get_power_state() {
  powered="$(echo "show" | bluetoothctl | grep -i powered | cut -d' ' -f2)"
  if [ "$powered" == "yes" ]; then text="Active"; else text="Inactive"; fi
  echo " $text"
}


if [ -n ${1} ]; then 
  ${1} "${@:2}" # issues command and supplies every arg after $1
fi
