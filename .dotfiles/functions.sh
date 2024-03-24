#!/bin/sh

# Colormap
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

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
  local answer;
  local asked="false";
  
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