#!/bin/sh

prompt_user() {
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