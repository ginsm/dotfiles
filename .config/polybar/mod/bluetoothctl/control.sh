#!/bin/bash

# ----------- Script Variables ----------- #
module_path="$HOME/.config/polybar/mod/bluetoothctl"
notif_time=3500


# ----------- Device Control ----------- #
dmenu_selector() {
  # Ensure that a device has been previously connected
  if [[ -n "$(get_devices)" ]]; then
    declare -A devices
    IFS=$'\n'

    # Populate the devices array
    for device in "$(get_devices)"; do
      id=$(echo $device | cut -d ' ' -f2)
      connected="$(device_connected $id)"
      key="$(echo $device | cut -d ' ' -f3-)$connected"
      devices["$key"]=$id;
    done

    # User prompt
    choice="$(echo ${!devices[@]} | dmenu -h 36 -nb '#101215')"
    choice_id=${devices[$choice]}

    if [[ -z "$choice" ]]; then
      notify-send --expire-time=$notif_time "Bluetooth" "Aborted dmenu selection."
    else
      # Disconnect route
      if [ "${choice: -1}" == "*" ]; then
        bluectl_exec "disconnect $choice_id"
        bluectl_exec "untrust $choice_id"
        # Alert the user
        notify-send --expire-time=$notif_time "Bluetooth" "${choice%\*} has been disconnected."
      # Connect route
      else
        notify-send --expire-time=$notif_time "Bluetooth" "Attempting to pair with $choice."

        bluectl_exec "untrust $choice_id"
        bluectl_exec "trust $choice_id"
        bluectl_exec "pair $choice_id"
        bluectl_exec "connect $choice_id"
        
        # Needed to determine successful connection
        # Times out after 10 seconds
        elapsed=0
        until [ $elapsed -gt 9 ]; do
          # Break the loop early if device is connected
          if [[ -n "$(device_connected $choice_id)" ]]; then
            break
          fi
          
          ((elapsed+=1))
          sleep 1
        done

        # Alert the user
        if [[ -n "$(device_connected $choice_id)" ]]; then
          notify-send --expire-time=$notif_time "Bluetooth" "$choice has been connected."
        else
          notify-send --expire-time=$notif_time "Bluetooth" "Unable to connect to $choice. Is it in pairing mode?"
        fi
      fi
    fi
  
  fi
}

bluectl_exec() {
  echo "$1" | bluetoothctl > /dev/null 2>&1
}

get_devices() {
  echo -e "$(echo "devices" | bluetoothctl | awk 'FNR > 4 {print last} {last=$0}')"
}

device_connected() {
  connected="$(echo "info $1" | bluetoothctl | grep -i connected | cut -d ' ' -f2)"
  if [ "$connected" == "yes" ]; then echo -e "*"; else echo -e ""; fi
}


# ----------- Bluetooth Control ----------- #
toggle_power() {
  if [ "$(get_powered_state)" == "yes" ]; then
    new_state="off"
  else
    new_state="on"
  fi

  bluectl_exec "power $new_state"
}

get_active_state() {
  if [ "$(get_powered_state)" == "yes" ]; then
    text="Active"
  else
    text="Inactive"
  fi

  echo " $text"
}

get_powered_state() {
  powered="$(echo "show" | bluetoothctl | grep -i powered | cut -d' ' -f2)"
  echo $powered;
}




# ----------- Command Issuer ----------- #
if [ -n ${1} ]; then 
  ${1} "${@:2}" # issues command and supplies every arg after $1
fi
