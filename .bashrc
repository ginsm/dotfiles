# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Don't save commands issued with duplicate lines or spaces into the history.
# See bash(1) for more options.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# The pattern ** used in a pathname expansion context will match all
# files (and zero or more directories and subdirectories).
shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Colored GCC warnings and errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Source all of the files located in $HOME/.dotfiles/
if [ -d $HOME/.dotfiles ]; then
    for f in $HOME/.dotfiles/*; do
    # echo -e $f
        if [[ -f $f ]]; then
            . "$f"
        fi
    done
fi

# Source all of the scripts located in $HOME/.dotfiles/scripts
if [ -d $HOME/.dotfiles/scripts ]; then
    for s in $HOME/.dotfiles/scripts/*; do
        if [[ -f $s ]]; then
            . "$s"
        fi
    done
fi

# Load nvm and its bash completion
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Yo, Go, will you just work??
export GO111MODULE=on

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
