#!/bin/sh

addPath() {
  export PATH="$1:$PATH"
}

addPath "$DOTFILES/bin"
addPath "/home/$USER/.local/bin"