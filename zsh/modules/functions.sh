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
      if [[ "$asked" == "false" ]]; then
        read "answer?$question";
        asked="true";
      else
        echo -e "You must provide an answer.";
        read "answer?$question";
      fi
    done
  else
    read "answer?$question";
  fi

  echo -e "$answer";
}

# Archive git branches
function archive_branch() {
  git checkout main
  git tag archive/$1 $1
  git branch -D $1
  git branch -d -r origin/$1
  git push --tags
  git push origin :$1
}