{

  #
  # ~/.bashrc
  #

  # If not running interactively, don't do anything
  [[ $- != *i* ]] && return

  # Don't save commands issued with duplicate lines or spaces into the history.
  # See bash(1) for more options.
  HISTCONTROL=ignoreboth

  # Append to the history file; don't overwrite it.
  shopt -s histappend

  # For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
  HISTSIZE=1000
  HISTFILESIZE=2000

  # The pattern ** used in a pathname expansion context will match all
  # files (and zero or more directories and subdirectories).
  shopt -s globstar

  # Make less more friendly for non-text input files, see lesspipe(1).
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # Enable programmable completion features (you don't need to enable
  # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
  # sources /etc/bash.bashrc).
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  export DISPLAY=:0;

  # Source all of the files located in $HOME/.dotfiles/
  if [ -d $HOME/.dotfiles ]; then
    for f in $HOME/.dotfiles/*; do
      . "$f"
    done
  fi

  # Source all of the scripts located in $HOME/.dotfiles/scripts
  if [ -d $HOME/.dotfiles/scripts ]; then
    for s in $HOME/.dotfiles/scripts/*; do
      . "$s"
    done
  fi

  # Source the PS1 file.
  . $HOME/.dotfiles/PS1.sh

  # Herbstclient Completion
  . /usr/share/bash-completion/completions/herbstclient

  # Load NVM and its bash completion.
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

  # Start libinput-gestures
  libinput-gestures-setup start

  # Set amixer pre-amp to 40%
  amixer set "Pre-Amp" '40%'

} &> /dev/null