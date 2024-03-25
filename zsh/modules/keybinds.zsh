# Allows ctrl + left/right arrow key navigation.
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Similar to above, but with alt.
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Bind space to accept zsh-autocompletion suggestion
bindkey '^@' autosuggest-accept