#!/bin/sh

addPath() {
  export PATH="$1:$PATH"
}

addPath "/home/$USER/.local/bin";

# addPath "/home/$USER/.local/share/gem/ruby/3.0.0/bin"

# addPath "/home/$USER/.sdkman/candidates/java/17.0.1-tem/bin/javap"