#!/bin/sh

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    setopt kshglob
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
# gfa is lifted from https://spin.atomicobject.com/fuzzy-find-git-add/
alias gfa='git ls-files -m -o --exclude-standard | fzf -m --print0 --reverse --border=sharp --margin=1% --padding=1% --header="Choose files to add" --header-first --no-info | xargs -0 -r -o git add'
alias gd='git diff'
alias gdc="git diff --cached"
alias gp='git push'
alias gf='git fetch'
alias gr='git reset'
alias gl='git log'

# Python aliases
alias python='python3.12'
alias py='python'
alias pip='pip3.12'

# Open location in explorer
alias open='explorer.exe'

# Source any local aliases.
if [ -f "$ALIASES.local" ]; then
  . "$ALIASES.local"
fi