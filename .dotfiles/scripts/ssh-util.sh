#!/bin/sh

# This script allows for easily generating, editing, and listing SSH
# profiles, and transferring to remote servers via rsync.
# Set the desired location with $SSHUTIL_DIR.

# Commands:
# ssh-util (-g|--generate) <profile> <user> <ip> <port> [comment]
# ssh-util (-t|--transfer) <profile> <location> <files>
# ssh-util (-e|--edit) <profile>
# ssh-util (-l|--list)

# ------------------------------------------------------- #
#                SSH Profile Generation               #
# ------------------------------------------------------- #

overwrite_ssh_profile_check() {
  local directory="$1";
  local question="That profile already exists. Do you wish to overwrite it (y/N)? "
  local answer;
  local asked="false";

  # Check if the directory exists.
  if [ -d "$directory" ]; then

    # Prompt the user and ask if they want to overwrite it.
    while true; do

      # Ask the user about overwriting the existing profile.
      read -p "$question" answer;
      asked="true";

      # End script if they answer with 'n', 'no', or press enter.
      if [[ "${answer,,}" == "n" || "${answer,,}" == "no" || "${answer,,}" == "" ]]; then
        echo -e "exit";
        return 1;
      fi

      # Continue with the rest of the script on 'y' or 'yes'.
      if [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]; then
        # Remove the directory.
        rm -r "$directory";
        break;
      fi

    done
  else
    echo -e "false";
  fi  
}

generate_ssh_profile() {
  # Alert the user that they will be prompted.
  if (( 5 > $# )); then
    echo -e "Usage: ssh-util -g <profile> <user> <ip> <port> [comment]";
    echo -e "Please fill out the following information:";
  fi

  # Handle user input (passed arguments and prompts).
  local profile=${1:-"$(prompt_user 'Profile Name: ' true)"};
  local user=${2:-"$(prompt_user 'User: ' true)"};
  local ip=${3:-"$(prompt_user 'IP: ' true)"};
  local port=${4:-"$(prompt_user 'Port (optional): ')"};
  local comment=${5:-"$(prompt_user 'Comment (optional): ')"};

  # Location of the profile and whether it exists.
  local directory="$SSHUTIL_DIR/profiles/$profile";
  local overwrite_status="$(overwrite_ssh_profile_check $directory)";

  # Ensure the directory (profile) does not exist.
  if [ "$overwrite_status" == "exit" ]; then
    return 1;
  fi
  
  # Make the profile directory.
  mkdir -p "$directory";

  # Create the profile configuration.
  {
    if [ -n "$comment" ]; then
      echo -e "# ${comment}";
    fi
    echo -e "Host $profile";
    echo -e "  HostName $ip";
    echo -e "  User $user";
    if [ -n "$port" ]; then 
      echo -e "  Port $port";
    fi
    echo -e "  IdentityFile $directory/keys/id_rsa";
  } >> "$directory/host.config";

  # Add the profile to the main config.
  if [ "$overwrite_status" == "false" ]; then
    echo -e "include $directory/host.config" >> "$SSHUTIL_DIR/hosts";
  fi

  generate_ssh_key $profile $comment
}

generate_ssh_key() {
  # Passed via generate_ssh_profile function.
  local profile="$1";
  local comment="$2";

  # Make the keys directory.
  local location="$SSHUTIL_DIR/profiles/$profile/keys";
  mkdir -p "$location";

  # Generate the key in the respective folder.
  ssh-keygen -t rsa -b 4096 -C "$comment" -f "$location/id_rsa";
}


# ------------------------------------------------------- #
#                     Edit SSH Profile                    #
# ------------------------------------------------------- #

edit_ssh_profile() {
  local profile="$1";
  vim "$SSHUTIL_DIR/profiles/$profile/host.config";
}


# ------------------------------------------------------- #
#                    List SSH Profiles                    #
# ------------------------------------------------------- #

list_ssh_profiles() {
  echo -e "$(ls -A $SSHUTIL_DIR/profiles)"
}

# ------------------------------------------------------- #
#                   File Transfer (rsync)                 #
# ------------------------------------------------------- #

transfer_files_rsync() {
  local profile="$1";
  local location="$2";

  if (( 3 > $# )); then
    echo -e "Not enough arguments.";
    echo -e "Usage: ssh-util -t <profile> <location> <...files>";
    return 0;
  fi
  
  rsync -hrvz --progress ${@:4} $profile:$location
}


# ------------------------------------------------------- #
#               Delegated Flag Handling              #
# ------------------------------------------------------- #

ssh-util() {
  if [[ "$1" == "-g" || "$1" == "--generate" ]]; then
    generate_ssh_profile "${@:2}";
  fi

  if [[ "$1" == "-t" || "$1" == "--transfer" ]]; then
    transfer_files_rsync "$@";
  fi

  if [[ "$1" == "-e" || "$1" == "--edit" ]]; then
    edit_ssh_profile "${@:2}";
  fi

  if [[ "$1" == "-l" || "$1" == "--list" ]]; then
    list_ssh_profiles;
  fi
}