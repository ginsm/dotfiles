#!/bin/sh

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    shopt -s extglob
    LS_COLORS="${LS_COLORS/:ow=*([^:]):/:ow=34;40:}"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls aliases and the like
alias ll='ls -alF'
alias la='ls -lA'
alias l='ls -CF'
alias cl='clear;ls'

# Search your bash history
alias ghist='history|grep'

# Git
alias gc='git commit'
alias gcm='git commit -m'
alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gp='git push'
alias gf='git fetch'

# Do not use rm, use trash-cli
alias rm='echo "Error: Did you mean to run a trash-cli command?"; false'
alias destroy='/bin/rm';

# Ctrl + Backspace to remove input word
bind '"\C-H":backward-kill-word'

# Source any local aliases (separation for git purposes).
if [ -f "$ALIASES.local" ]; then
  . "$ALIASES.local"
fi
