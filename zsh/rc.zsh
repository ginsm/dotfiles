
export EDITOR="$(which vim)"

# ANCHOR - Starship
# Prevent newline at top on clear and start
precmd() {
  if [ ! -z "$BUFFER" ]; then
    precmd() {
      precmd() {
        echo
      }
    }
  fi
}

# Start Starship
eval "$(starship init zsh)"


# ANCHOR - SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"