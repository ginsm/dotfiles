# This script allows you to save and load herbstluftwm layouts quickly and easily.

# -------------- Option Handlers -------------- #
__layout_save() {
  if (( 1 > $# )); then
    printf '%s\n' \
      "Usage: layout save <profile>" \
      "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local hc_dump="$(herbstclient dump | perl -pe 's/\s\dx.{0,7}//g')";

  echo -e ${hc_dump} > "${LAYOUTDIR}/${profile}.layout";
  echo -e "Saved as '${profile}.layout' in '${LAYOUTDIR}'.";
}

__layout_load() {
  if (( 1 > $# )); then
    printf '%s\n' \
      "Usage: layout save <profile>" \
      "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local layout_path="${LAYOUTDIR}/${profile}.layout";

  if [ -f "${layout_path}" ]; then
    herbstclient load "$(cat ${layout_path})";
    echo -e "Successfully loaded layout '${profile}'.";
  else
    echo -e "Error: Layout '${profile}' does not exist. Run 'layout list' for available layouts.";
  fi
}

__layout_list() {
  echo -e "[ Available Layouts ]";
  find ${LAYOUTDIR} -type f -printf '%f\n' | perl -pe 's/.layout$//g';
}

__layout_remove() {
  if (( 1 > $# )); then
    printf '%s\n' \
      "Usage: layout save <profile>" \
      "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local file_path="${LAYOUTDIR}/${profile}.layout";

  if [ -f "${file_path}" ]; then
    rm "${LAYOUTDIR}/${profile}.layout";
    echo -e "Successfully removed layout '${profile}'."
  else
    echo -e "Error: The profile '$profile' already doesn't exist. Skipping.";
  fi
  
}

# -------------- Help Menu -------------- #
__layout_help_menu() {
  printf '%s\n' \
    "Usage: layout [OPTIONS]" \
    "Options:" \
    "" \
    "save, s <profile>        Save a layout" \
    "load, l <profile>        Load a layout" \
    "remove, r <profile>      Remove a layout" \
    "list, ls                 List available layouts";
}

# -------------- Utility Functions -------------- #
layout_has_argument() {
  if [ $# -eq 0 ]; then
    echo "Error: No arguments supplied";
    return 1;
  fi
}

__layout_command_flag() {
  local flags="$1";
  local command="$2";
  local issued_flag="$3";

  for flag in $flags; do
    if [[ "$flag" == "$issued_flag" ]]; then
      __layout_command_ran="true";
      "__layout_$command" "${@:4}";
    fi
  done
}

layout() {
  __layout_command_ran="false";

  __layout_command_flag "save s" save "$@";
  __layout_command_flag "load l" load "$@";
  __layout_command_flag "remove r" remove "$@";
  __layout_command_flag "list ls" list "$@";

  if [[ "$__layout_command_ran" == "false" ]]; then
    __layout_help_menu;
  fi
}