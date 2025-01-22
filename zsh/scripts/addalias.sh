#!/bin/sh

# Alias is an utility tool I wrote to replace the native 'alias' command.
# I wanted to be able to set aliases in the terminal with ease.
# Usage: addalias <alias> <command> [comment]

addalias() {
  # Set up the local variables.
  local alias="$1"
  local command="$2"
  local comment="$3"
  local local_aliases="${ALIASES}.local"

  # Ensure the necessary arguments are present
  if [ -z "$alias" ] || [ -z "$command" ]; then
    printf "Usage: addalias <alias> <command> [comment]\n"
    return 0
  fi

  # Create the local aliases file
  if [ ! -f "$local_aliases" ]; then
    mkdir -p "$( dirname -- "$local_aliases" )"
    touch "$local_aliases"
    {
      echo -e "#!/bin/sh"
    } >> "$local_aliases"
  fi

  # Set comment to the date if empty.
  if [ -z "$comment" ]; then comment="$(date)"; fi

  # Write the comment, alias, and command to file.
  {
    echo -e ""
    echo -e "# $comment"
    echo "alias $alias='$command'"
  } >> "$local_aliases"

  # Source the local aliases file.
  . "$local_aliases"
}
