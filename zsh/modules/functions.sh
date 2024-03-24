#!/bin/sh

# ... I'm going to do it anyway.
function cd() {
  builtin cd "$@" && ls --color=auto
}

# Mount a particular USB (WSL)
function mntusb() {
    local drive="$1";
    mkdir /mnt/$drive;
    mount -t drvfs $drive: /mnt/$drive;
}

# Used inside various scripts.
function prompt_user() {
  local question=$1;
  local required=$2;
  local asked="false";
  local answer;
  
  if [ -n "$required" ]; then
    while [ -z "$answer" ]; do
      if [ "$asked" == "false" ]; then
        read -p "$question" answer;
        asked="true";
      else
        echo -e "You must provide an answer.";
        read -p "$question" answer;
      fi
    done
  else
    read -p "$question" answer;
  fi

  echo -e "$answer";
}