#!/bin/sh

# Sandbox is an utility tool I wrote to keep my machine clean from
# clutter and organized.
#
# It allows you to create a file on the fly and opens it with VS Code.
# It will sort the file in your sandbox directory (@see variables.sh)
# by extension and category.
#
# Usage: sb <path/to/file.ext> <category number>

# Create a file in the sandbox
sandbox() {
  # Set up script variables
  local path_="${1}"
  category_="${2}"

  # Issue the category selector prompt
  if [ -z "$category_" ]; then category_selector; fi

  # Split the filepath into [dir]/[file].[ext]
  parse_path "$path_"

  # Create the necessary path and cd to it
  mkdir -pv "$dir_"
  cd "$dir_"
  printf "sb: Moved to '$dir_'\n"

  # Create the file in that path
  touch "$full_"
  printf "sb: Opening '$file_'\n"

  # Open the directory in vscode.
  code "$dir_"

  # Open up the file afterwards.
  code "$full_"
}

# Prompts you to select between 5 different categories.
category_selector() {
  # Clarify instructions
  printf "Please select a category via its number:\n"

  # Question Prompt
  PS3="Which category would you like to use? "

  # Category picker
  select cat_ in \
    "throw-aways" "concepts" "tests" "projects" "studies" "snippets"
  do
    # Set the category and ensure it is not empty (out of range)
    category_="$cat_"
    if [ -n "$category_" ]; then break; fi

    # Throw an out of range error
    printf "That number is out of range.\n"
  done
}

# Splits the file path up until [dir][file][ext]
parse_path() {
  # Get the path, file, and extension values
  local file="${1##*/}"
  local ext="${file##*.}"
  local file="${file%.*}"
  local dir="$(dirname "$1")/"

  # Reassign the extension if one wasn't provided
  if [ $ext = $file ]; then ext="unsorted"; fi

  # Reassign the dir if one wasn't provided
  if [ "$dir" = "./" ]; then dir=""; fi

  # Do not append the ext if it is listed as unsorted
  if [ "$ext" = "unsorted" ]; then
    file_="$file"
  else
    file_="$file.$ext"
  fi

  # Add the dir_ and full_ (path) variables
  dir_="$SANDBOX/$ext/$category_/$dir"
  full_="$dir_$file_"
}