# Ensure something exists before sourcing
source_if_exists() {
  if test -r "$1"; then
    source "$1"
  fi  
}

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Source specific files
source_if_exists $HOME/.env.sh

# Source all modules
if [ -d $DOTFILES/zsh/modules ]; then
  for module in $DOTFILES/zsh/modules/*; do
    source_if_exists $module
  done
fi

# Source all scripts
if [ -d $DOTFILES/zsh/scripts ]; then
  for script in $DOTFILES/zsh/scripts/*; do
    source_if_exists $script
  done
fi

export VISUAL=vim
export EDITOR=vim

# ANCHOR - Starship
precmd() {
  last_command=$(history | tail -1 | sed "s/^[ ]*[0-9]*[ ]*//")
  if [ "$last_command" != "clear" ]; then
    echo
  fi
}

# Start Starship
eval "$(starship init zsh)"


# ANCHOR - SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"