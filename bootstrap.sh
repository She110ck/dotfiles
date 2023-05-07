#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF >&2
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Set up my workspace and dotfiles.
Tuned especially for thinkpad e15 with arch.

Available options:

-a,  --arch           Install arch required packages (requires root)
-c,  --config         Link config files (prefer run as non-root)
-m,  --minimal        Link config mimal files for server (prefer run as non-root)
-uc, --ubuntu-cli     Minimal set of tools for ubuntu servers (requires root)
-s,  --services       Enable/configure services.To best run after installing yay packages (requires root)
-y,  --yay            Install yay (run only as non-root)
-yp, --yay-pkg        Install yay packages (run only as non-root)
-h,  --help           Print this help and exit
-v,  --verbose        Print script debug info

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
      -h  | --help) usage ;;
      -v  | --verbose) set -x ;;
      --no-color) NO_COLOR=1 ;;
      --os ) # example named parameter
        OS="${2-}"
        shift
        ;;
      -a  | --arch)       install_arch ;;
      -c  | --config)     config_files ;;
      -m  | --minimal)    config_minimal ;;
      -uc | --ubuntu-cli) install_ubuntu_cli;;
      -s  | --services)   init_services ;;
      -y  | --yay)        install_yay ;;
      -yp | --yay-pkg)    install_yay_pkgs ;;
      -?*) die "Unknown option: $1" ;;
      *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  #[[ -z "${OS-}" ]] && die "Missing required parameter: param"
  #[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"
  [[ ${#args[@]} -eq 0 ]] && msg "Bad usage.\nTry with '--help' for more information."

  return 0
}
# 
setup_colors


# script logic here

LOGFILE_DIR=/var/log/bootstrap.log
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)


install_yay(){
  # as non-root user
  if ! type "yay" &>/dev/null;
  then
    pushd .
    cd $(mktemp -d)
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    popd
    # permanent answer to yay questions
    yay --save --answerdiff None --answerclean None --removemake
  else
  msg "Yay is ${GREEN}already installed${NOF}!"
  fi
}

install_yay_pkgs() {
  msg "${RED}Installing${NOF} arch packages from AUR. tail -f ${LOGFILE_DIR} to see"
  yes | yay -Syu --need --noconfirm brave-bin vscodium thinkfan touchegg touche >> LOGFILE_DIR 2>&1
}
# maybe xidlehook over xautolock


install_arch() {
  msg "${RED}Installing${NOF} arch packages. tail -f ${LOGFILE_DIR} to see"

  # alacritty tmux
  yes | pacman -Syu --need --noconfirm git vim python-pip ranger base-devel \
    firefox chromium xfce4-terminal volumeicon \
    nitrogen flameshot peek viewnior mpd ncmpcpp mpv thunar \
    syncthing keepassxc alacritty \
    blueman-manager bluez pulseaudio-bluetooth \
    tlp xss-lock lxsession xautolock sysstat \
    mosh ttf-firacode-nerd ttf-sourcecodepro-nerd ttf-anonymouspro-nerd ttf-hack-nerd noto-fonts-emoji \
    iotop telnet iftop bat exa
       >> $LOGFILE_DIR 2>&1
}

init_services(){
  # enable bluetooth
  systemctl enable bluetooth
  systemctl enable tlp
  systemctl mask systemd-rfkill.service
  systemctl mask systemd-rfkill.socket

  # collects system stats
  systemctl enable sysstat

  # sync hardware/software clock
  timedatectl set-local-rtc 1
  
  # yay installed daemons
  if type "yay" &>/dev/null;
  then
    systemctl enable touchegg 
    systemctl enable thinkfan.conf
  else
    msg "${YELLOW}Yay not found.${NOF} Skipping yay daemons."
  fi
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
    mv "${LNK}" "${BACKUP_DIR}/${1#.config/}.${DATE_NOW}" 
  fi
  # file found
  if [ ! -L "${LNK}" ] && [ -f "${LNK}" ]
  then
    msg "Found ${YELLOW}${LNK}${NOF}! Backup to ${BACKUP_DIR} ..."
    mv "${LNK}" "${BACKUP_DIR}/${1#.config/}.${DATE_NOW}" 
  fi
  
  # if link parent directory doesn't exists, create
  if [ ! -d "$(dirname ${LNK})" ]
  then
    mkdir -p "$(dirname ${LNK})"
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

# only for servers
config_minimal() {

  config_init ".vim"                   "vim"
  config_init ".gitconfig"             "gitconfig"
  config_init ".config/nano"           "nano"
  config_init ".config/tmux"           "tmux"
  config_init ".config/ranger"         "ranger"

}

# usually I have only ubuntu servers
install_ubuntu_cli() {
  msg "${RED}Installing${NOF} ubuntu server packages. tail -f ${LOGFILE_DIR} to see"
  apt update >> /dev/null 2>&1
  apt install -y vim git ranger tmux htop telnet mosh >> $LOGFILE_DIR 2>&1
}

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
  config_init ".config/i3blocks"       "i3blocks"
  config_init ".config/ranger"         "ranger"
  config_init ".config/rofi"           "rofi"
  config_init ".config/touchegg"       "touchegg"
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
    TOUCH $USER_HOME/.config/nitrogen/bootstrap_init_flag
  fi

  msg "${CYAN}Install tmux plugin manager...${NOF}"
  if [! -d "$USER_HOME/.tmux" ]
  then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm &>/dev/null
  else
    msg "${GREEN}Found tmux plugin manager...${NOF}"
  fi
}

parse_params "$@"

