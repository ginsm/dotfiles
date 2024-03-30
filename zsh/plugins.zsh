# List of plugin download urls
declare -A plugins_url
plugins_url[zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
plugins_url[zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
plugins_url[zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
plugins_url[fzf-tab]="https://github.com/Aloxaf/fzf-tab"

plugins=()

for plugin url in ${(kv)plugins_url}; do
    # Check if plugin has been installed
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]]; then
        echo "Missing zsh plugin '$plugin'; downloading..."
        git clone $url ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin
    fi

    # Add plugin to plugins array
    plugins+=( "$plugin" )
done