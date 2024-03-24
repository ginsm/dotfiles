#!/bin/sh

addPath() {
  export PATH="$1:$PATH"
}

addPath "/home/$USER/.local/bin";