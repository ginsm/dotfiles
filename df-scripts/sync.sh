# Get the directory of this script.
DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Synchronizes the dotfiles to $HOME; excluding any files located in 'sync.exclude'.
rsync \
    --exclude-from "${DOTFILES}/sync.exclude" \
    -r "${DOTFILES}/.." ~

# Source the .bashrc file
. $HOME/.bashrc

# Load Xresources
xrdb ~/.Xresources