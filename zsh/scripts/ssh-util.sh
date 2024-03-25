#!/bin/sh

# This script allows for easily generating, editing, and listing SSH
# profiles, and transferring to remote servers via rsync.
# Set the desired location with $SSHUTIL_DIR.

# ------------------------------------------------------- #
#                   Utility Functions                     #
# ------------------------------------------------------- #

function __su_knock_profile() {
  local profile="$1"
  local directory="$SSHUTIL_DIR/profiles/$profile"

  # Check if a knock sequence is available and issue it
  if [ -f "$directory/knock_sequence" ]; then
    knock -d 300 $(cat $directory/knock_sequence);
  fi
}

function __su_command_flag() {
  local flags="$1";
  local command="$2";
  local issued_flag="$3";

  for flag in $=flags; do
    if [[ "$flag" == "$issued_flag" ]]; then
      __su_command_ran="true";
      "__su_$command" "${@:4}";
    fi
  done
}


# ------------------------------------------------------- #
#                SSH Profile Generation                   #
# ------------------------------------------------------- #

function __su_overwrite_ssh_profile_check() {
  local directory="$1";
  local question="That profile already exists. Do you wish to overwrite it (y/N)? ";
  local answer;
  local asked="false";

  # Check if the directory exists.
  if [ -d "$directory" ]; then
    # Prompt the user and ask if they want to overwrite it.
    while true; do
      # Ask the user about overwriting the existing profile.
      read "answer?$question";
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

function __su_generate_ssh_profile() {
  # Alert the user that they will be prompted.
  if (( 5 > $# )); then
    echo -e "Usage: sshu -g <profile> <user> <ip> <port> [knock] [comment]";
    echo -e "Please fill out the following information.";
  fi

  # Handle user input (passed arguments and prompts).
  local profile=${1:-"$(prompt_user 'Profile Name: ' true)"};
  local user=${2:-"$(prompt_user 'User: ' true)"};
  local ip=${3:-"$(prompt_user 'IP: ' true)"};
  local port=${4:-"$(prompt_user 'Port (optional): ')"};
  local knock_sequence=${5:-"$(prompt_user 'Knock Sequence (optional): ')"};
  local comment=${6:-"$(prompt_user 'Comment (optional): ')"};

  # Generate the SSH config file (.ssh/config).
  __su_generate_ssh_config

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

  # Save the knock sequence to a file
  if [ -n "$knock_sequence" ]; then
    echo -e "$ip $knock_sequence" >> $directory/knock_sequence;
  fi
  
  # Add the profile to the main config.
  if [ "$overwrite_status" == "false" ]; then
    echo -e "include $directory/host.config" >> "$SSHUTIL_DIR/hosts";
  fi

  __su_generate_ssh_key "$profile" "$comment";

  # Output the pub key
  __su_view_profile_pub_key $profile;
}

function __su_generate_ssh_key() {
  # Passed via __su_generate_ssh_profile function.
  local profile="$1";
  local comment="$2";

  # Make the keys directory.
  local directory="$SSHUTIL_DIR/profiles/$profile/keys";
  mkdir -p "$directory";

  # Generate the key in the respective folder.
  ssh-keygen -t ed25519 -C "$comment" -f "$directory/id_ed25519";
}

function __su_generate_ssh_config() {
  local directory="$HOME/.ssh";
  if [ ! -f "$directory/config" ]; then
    echo -e "include \"$SSHUTIL_DIR/hosts\"" >> $directory/config;
  fi
}


# ------------------------------------------------------- #
#                     Edit SSH Profile                    #
# ------------------------------------------------------- #

function __su_edit_ssh_profile() {
  # Alert the user that they will be prompted.
  if (( 1 > $# )); then
    echo -e "Usage: sshu -e <profile>";
    echo -e "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local directory="$SSHUTIL_DIR/profiles/$profile";

  if [[ -d "$directory" ]]; then
    vim "$directory/host.config";
  else
    echo -e "sshu: That profile does not exist.";
  fi
}


# ------------------------------------------------------- #
#                    List SSH Profiles                    #
# ------------------------------------------------------- #

function __su_list_ssh_profiles() {
  echo -e "$(ls -A $SSHUTIL_DIR/profiles)";
}


# ------------------------------------------------------- #
#                   View Profile Pub Key                  #
# ------------------------------------------------------- #

function __su_view_profile_pub_key() {
  # Alert the user that they will be prompted.
  if (( 1 > $# )); then
    echo -e "Usage: sshu -p <profile>";
    echo -e "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local directory="$SSHUTIL_DIR/profiles/$profile";

  if [[ -d "$directory" ]]; then
    echo -e "\"${profile}\"s public key";
    echo -e "-------------------------------------------------------";
    echo -e "$(cat $SSHUTIL_DIR/profiles/$profile/keys/*.pub)";
    echo -e "-------------------------------------------------------";
  else
    echo -e "sshu: That profile does not exist.";
  fi
}


# ------------------------------------------------------- #
#                   File Transfer (rsync)                 #
# ------------------------------------------------------- #

function __su_transfer_files_rsync() {
  # Alert the user that they will be prompted.
  if (( 2 > $# )); then
    echo -e "Usage: sshu -t <source|target> <target|source>";
  fi
  
  local arg1=${1:-"$(prompt_user 'Source|target: ' true)"};
  local arg2=${2:-"$(prompt_user 'Target|source: ' true)"};

  for arg in $arg1 $arg2; do
    if [[ $arg == *":"* ]]; then
      local profile="$(cut -d ':' -f 1 <<< $arg)";
      local directory="$SSHUTIL_DIR/profiles/$profile";
    fi
  done

  # Issue the appropriate knock sequence if it exists
  if [[ -d "$directory" ]]; then
    __su_knock_profile $profile;
  fi

  rsync -hrvze ssh --progress "$arg1" "$arg2";
}


# ------------------------------------------------------- #
#                   Connecting via SSH                    #
# ------------------------------------------------------- #
function __su_connect_ssh() {
  # Alert the user that they will be prompted.
  if (( 1 > $# )); then
    echo -e "Usage: sshu -c <profile>";
    echo -e "Please fill out the following information.";
  fi

  local profile=${1:-$(prompt_user 'Profile: ' true)};
  local directory="$SSHUTIL_DIR/profiles/$profile";

  if [[ -d "$directory" ]]; then
    # Knock the appropriate ports
    __su_knock_profile $profile;
    
    # Connect via the SSH profile
    ssh $profile;
  fi
}

function __su_run_command() {
  # Alert the user that they will be prompted.
  if (( 1 > $# )); then
    echo -e "Usage: sshu -r <profile> <command>";
    echo -e "Please fill out the following information.";
  fi

  local profile=${1:-"$(prompt_user 'Profile: ' true)"};
  local command=${2:-"$(prompt_user 'Command: ' true)"};

  local directory="$SSHUTIL_DIR/profiles/$profile";

  if [[ -d "$directory" ]]; then
    # Knock the appropriate ports
    __su_knock_profile $profile;
    
    # Connect via the SSH profile
    ssh $profile $command;
  fi
}


# ------------------------------------------------------- #
#                     Print Help Menu                     #
# ------------------------------------------------------- #

function __su_help_menu() {
  echo -e "Usage: sshu [OPTIONS] \n";
  echo -e "Options:";
  echo -e "  -l                                                      List available profiles";
  echo -e "  -g <profile> <user> <ip> <port> [knockseq] [comment]    Generate a SSH profile";
  echo -e "  -c <profile>                                            Connect to a SSH profile";
  echo -e "  -e <profile>                                            Edit a profile";
  echo -e "  -p <profile>                                            View a profile's id_rsa.pub";
  echo -e "  -t <target|source> <target|source>                      Transfer files bidirectionally";
  echo -e "  -r <profile> <command>                                  Transfer files bidirectionally";
}


# ------------------------------------------------------- #
#                 Delegated Flag Handling                 #
# ------------------------------------------------------- #

function sshu() {
  __su_command_ran="false";

  __su_command_flag "-g --generate" generate_ssh_profile "$@";
  __su_command_flag "-p --pubkey" view_profile_pub_key "$@";
  __su_command_flag "-e --edit" edit_ssh_profile "$@";
  __su_command_flag "-l --list" list_ssh_profiles "$@";
  __su_command_flag "-t --transfer" transfer_files_rsync "$@";
  __su_command_flag "-c --connect" connect_ssh "$@";
  __su_command_flag "-h --help" __su_help_menu;
  __su_command_flag "-r --run" run_command "$@";

  if [[ "$__su_command_ran" == "false" ]]; then
    __su_help_menu;
  fi
}