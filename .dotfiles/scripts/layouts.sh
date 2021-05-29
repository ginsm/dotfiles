# This script allows you to save and load herbstluftwm layouts quickly and easily.

layout_has_argument() {
  if [ $# -eq 0 ]; then
    echo "Error: No arguments supplied"
    return 1;
  fi
}

layout() {
  layout_has_argument ${@};
  local layout_path="${HOME}/.dotfiles/layouts/${1}.layout";
  if [ -f "${layout_path}" ]; then
    echo -e "Loading layout '${1}'."
    herbstclient load "$(cat ${layout_path})";
  else
    echo -e "Error: Layout '${1}' does not exist."
  fi
}

dumplayout() {
  layout_has_argument ${@};
  local layout_path="${HOME}/.dotfiles/layouts/${1}.layout";
  herbstclient dump > "${layout_path}";
}