#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF >&2 
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Set up my cli workspace.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  # NOF means NOFORMAT
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOF='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' 
    ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' 
    CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOF='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  # echo >&2 -e "${1-}"
  printf >&2  -- "${1-}\n"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
      -h | --help) usage ;;
      -v | --verbose) set -x ;;
      --no-color) NO_COLOR=1 ;;
      -f | --flag) flag=1 ;; # example flag
      -p | --param) # example named parameter
        param="${2-}"
        shift
        ;;
      -a | --arch) install_arch ;;
      -t | --time) fix_time ;;
      -c | --config) config_files ;;
      -?*) die "Unknown option: $1" ;;
      *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  #[[ -z "${param-}" ]] && die "Missing required parameter: param"
  #[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}
# 
setup_colors


# script logic here

LOGFILE_DIR=/var/log/bootstrap.log
BACKUP_DIR="${script_dir}/backup"
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

install_brave(){
# as non-root user
  pushd .
  cd $(mktemp -d)
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  popd

}

install_arch() {
  msg "${RED}Installing${NOF} arch packages. tail -f ${LOGFILE_DIR} to see"
  
  # alacritty tmux
  yes | pacman -Syu git vim ranger base-devel firefox xfce4-terminal volumeicon nitrogen thunar syncthing keepassxc

# >> $LOGFILE_DIR 2>&1
}

fix_time() {
  timedatectl set-local-rtc 1
}

config_init() {
  # get 2 argument: destination and dotfile location
  # $1 e.g. .vim
  # $2 e.g.  vim
  LNK="${USER_HOME}/$1" 
  TRGT="${script_dir}/$2" 
  DATE_NOW=$(date +'%Y%m%d-%H%M%S')

  [[ -z "$1" ]] && die "Missing required first  parameter"
  [[ -z "$2" ]] && die "Missing required second parameter"

  # if backup dir doesn't exists, create
  if [ ! -d "${BACKUP_DIR}" ]
  then
    mkdir -p "$BACKUP_DIR"
  fi

  # directory found
  if [ ! -L "${LNK}" ] && [ -d "${LNK}" ]
  then
    msg "Found ${YELLOW}${LNK}${NOF}! Backup to ${BACKUP_DIR}..."
    mv "${LNK}" "${BACKUP_DIR}/$1.${DATE_NOW}" 
  fi
  # file found
  if [ ! -L "${LNK}" ] && [ -f "${LNK}" ]
  then
    msg "Found ${YELLOW}${LNK}${NOF}! Backup to ${BACKUP_DIR} ..."
    mv "${LNK}" "${BACKUP_DIR}/$1.${DATE_NOW}" 
  fi

  # remove if another link
  if [ -L "${LNK}" ] && [ ! "$(readlink ${LNK})" -ef "${TRGT}" ]
  then
    msg "Found symlink targeted to $(readlink ${LNK})! ${RED}Removing ...${NOF}"
    rm  "${LNK}"
  fi

  # create link if doesn't exist
  if [ ! -L "${LNK}"  ] ; then
    msg "Creating fresh symlink: ${GREEN}${LNK} -> ${TRGT}${NOF}"
    ln -s "${TRGT}" "${LNK}" 
    # chown -h ${SUDO_USER:$USER}:users ${LNK}
  fi
}

#echo $script_dir

config_files() {
# $1 related to user home
# $2 related to current directory
config_init ".vim"                   "vim"
config_init ".config/tmux"           "tmux"
config_init ".config/i3"             "i3"
config_init ".config/dunst"          "dunst"
config_init ".config/i3status"       "i3status"
config_init ".config/ranger"         "ranger"
config_init ".config/rofi"           "rofi"
config_init ".config/xfce4/terminal" "xfce4/terminal"

config_init ".gitconfig"             "gitconfig"
}




parse_params "$@"

msg "${RED}Read parameters:${NOF}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"