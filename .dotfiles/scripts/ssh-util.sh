#!/bin/sh

# This script allows for easily generating, editing, and listing SSH
# profiles, and transferring to remote servers via rsync.
# Set the desired location with $SSHUTIL_DIR.

# Commands:
# ssh-util (-g|--generate) <profile> <user> <ip> <port> [comment]    # Generates a SSH profile
# ssh-util (-vp|--view-pub) <profile>                                # Outputs profile's id_rsa.pub
# ssh-util (-e|--edit) <profile>                                     # Edit a SSH profile
# ssh-util (-l|--list)                                               # List SSH profiles
# ssh-util (-t|--transfer) <profile> <location> <files>              # Transfer files to remote server via SSH (rsync)

# ------------------------------------------------------- #
#                SSH Profile Generation               #
# ------------------------------------------------------- #

__su_overwrite_ssh_profile_check() {
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

__su_generate_ssh_profile() {
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
  local overwrite_status="$(__su_overwrite_ssh_profile_check $directory)";

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

  __su_generate_ssh_key "$profile" "$comment";
}

__su_generate_ssh_key() {
  # Passed via __su_generate_ssh_profile function.
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

__su_edit_ssh_profile() {
  local profile="$1";
  vim "$SSHUTIL_DIR/profiles/$profile/host.config";
}


# ------------------------------------------------------- #
#                    List SSH Profiles                    #
# ------------------------------------------------------- #

__su_list_ssh_profiles() {
  echo -e "$(ls -A $SSHUTIL_DIR/profiles)"
}


# ------------------------------------------------------- #
#                   View Profile Pub Key                  #
# ------------------------------------------------------- #

__su_view_profile_pub_key() {
  local profile="$1";
  echo -e "\"${profile}\" id_rsa.pub"
  echo -e "-------------------------------------------------------";
  echo -e "$(cat $SSHUTIL_DIR/profiles/$profile/keys/id_rsa.pub)";
  echo -e "-------------------------------------------------------";
}


# ------------------------------------------------------- #
#                   File Transfer (rsync)                 #
# ------------------------------------------------------- #

__su_transfer_files_rsync() {
  local profile="$1";
  local location="$2";

  if (( 3 > $# )); then
    echo -e "Not enough arguments.";
    echo -e "Usage: ssh-util -t <profile> <location> <...files>";
    return 0;
  fi
  
  rsync -hrvz --progress ${@:3} $profile:$location
}


# ------------------------------------------------------- #
#                 Delegated Flag Handling                 #
# ------------------------------------------------------- #

__su_command_flag() {
  local flags="$1";
  local command="$2";
  local issued_flag="$3";

  for flag in $flags; do
    if [[ "$flag" == "$issued_flag" ]]; then
      "__su_$command" "${@:4}";
    fi
  done
}

ssh-util() {
  # Delegate command flags
  __su_command_flag "-g --generate" generate_ssh_profile "$@";
  __su_command_flag "-vp --view-pub" view_profile_pub_key "$@";
  __su_command_flag "-e --edit" edit_ssh_profile "$@";
  __su_command_flag "-l --list" list_ssh_profiles "$@";
  __su_command_flag "-t --transfer" transfer_files_rsync "$@";
}