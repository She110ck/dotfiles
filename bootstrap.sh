#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF >&2
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Set up my dotfiles.

Available options:

-a, --arch      Install arch required packages (requires root)
-c, --config    Link config files
-t, --time      Sync hardware/software clock
-b, --brave     Install brave (run only as non-root)
-h, --help      Print this help and exit
-v, --verbose   Print script debug info

EOF
exit
}


# -f, --flag      Some flag description
# -p, --param     Some param description


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
      -b | --brave)  install_brave ;;
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
# install vscodium via yay 
# install thinkfan via yay
# install touchegg, touche via yay for touchpad gesture
# maybe xidlehook over xautolock

# disable dmesg logs:
# rtw_8822ce 0000:05:00.0: PCIe Bus Error: severity=Corrected, type=Physical Layer, (Receiver ID)
# copy .service to /etc/systemd/system/ and execute:
# systemctl daemon-reload
# systemctl enable fix_intel_realtek_wifi_log_sh-t.service
# systemctl start fix_intel_realtek_wifi_log_sh-t.service
# https://gist.github.com/Brainiarc7/3179144393747f35e5155fdbfd675554

install_arch() {
  msg "${RED}Installing${NOF} arch packages. tail -f ${LOGFILE_DIR} to see"

  # alacritty tmux
  yes | pacman -Syu git vim python-pip ranger base-devel firefox chromium xfce4-terminal volumeicon \
    nitrogen flameshot peek viewnior mpd ncmpcpp thunar \
    syncthing keepassxc \
    blueman-manager bluez pulseaudio-bluetooth \
    tlp xss-lock lxsession xautolock \
    mosh ttf-anonymous-pro ttf-hack \
    iotop telnet iftop bat exa
      # >> $LOGFILE_DIR 2>&1

  # enable bluetooth
  systemctl enable bluetooth
  systemctl enable tlp
  systemctl mask systemd-rfkill.service
  systemctl mask systemd-rfkill.socket
  
  # systemctl enable touchegg
  # copy modprobe.d/ to /etc/modprobe.d/ to prevent PCI errors
  # fan control
  # 
  # comment  /usr/lib/modprobe.d/thinkpad_acpi.conf to install thinkfan
  # cp thinkfan.conf to /etc/thinkfan.conf (can require define hwmon[0-9] number)
  # systemctl enable thinkfan.conf

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
  BACKUP_DIR="${script_dir}/backup"


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
  config_init ".zshrc"                 "zshrc"
  config_init ".gitconfig"             "gitconfig"
  config_init ".aliases"               "aliases"
  config_init ".config/nano"           "nano"
  config_init ".config/tmux"           "tmux"
  config_init ".config/i3"             "i3"
  config_init ".config/dunst"          "dunst"
  config_init ".config/i3status"       "i3status"
  config_init ".config/ranger"         "ranger"
  config_init ".config/rofi"           "rofi"
  config_init ".config/xfce4/terminal" "xfce4/terminal"
  config_init ".config/zsh"            "zsh"
  config_init ".config/fish"           "fish"
  config_init ".config/alacritty"      "alacritty"
  config_init ".config/mpd"            "mpd"
  config_init ".config/ncmpcpp"        "ncmpcpp"
  config_init ".config/picom"          "picom"
  config_init "Pictures/nitrogen"      "nitrogen"

  # install oh-my-zsh framework
  if [ ! -d $USER_HOME/.oh-my-zsh ] ; 
  then
    git clone git@github.com:ohmyzsh/ohmyzsh.git $USER_HOME/.oh-my-zsh
  fi
  if [ ! -f $USER_HOME/.config/nitrogen/bootstrap_init_flag ] ;
  then
    # init nitrogen wallpaper
    nitrogen --set-zoom-fill --save "$USER_HOME/Pictures/nitrogen/wall.jpg"
    touch $USER_HOME/.config/nitrogen/bootstrap_init_flag
  fi
}


parse_params "$@"

msg "${RED}Read parameters:${NOF}"
#msg "- flag: ${flag}"
#msg "- param: ${param}"
#msg "- arguments: ${args[*]-}"
