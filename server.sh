#!/bin/sh
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/She110ck/dotfiles/master/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/She110ck/dotfiles/master/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/She110ck/dotfiles/master/install.sh)"
#
set -e

HOME="${HOME:-$(eval echo ~$USER)}"
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NOF='\033[0m'

function version { printf "%d%d%d\n" ${1:0:1} ${1:2:1} "'${1:3:1}";  }


if ! type "git" &>/dev/null;
then
  printf "${YELLOW}Git is not installed${NOF}\n"
  exit
fi


printf "${CYAN}Install tmux plugin manager...${NOF}\n"
if [ ! -d "$HOME/.tmux" ]
then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm &>/dev/null
else
  printf "${GREEN}Found tmux plugin manager...${NOF}\n"
fi

printf "${CYAN}Copy tmux config...${NOF}\n"
mkdir -p $HOME/.config/tmux/
if [ ! -f $HOME/.config/tmux/tmux.conf ]
then
  curl -s https://raw.githubusercontent.com/She110ck/dotfiles/master/tmux/tmux.conf --output $HOME/.config/tmux/tmux.conf
fi
TMX_VER=$(tmux -V | cut -d ' ' -f2) 
if [ $(version 3.1 ) -ge $(version $TMX_VER) ];
then
  printf "${CYAN}Tmux old version. Symlink to ~/.tmux.conf required...${NOF}\n"
  rm $HOME/.tmux.conf
  ln -s $HOME/.config/tmux/tmux.conf $HOME/.tmux.conf
fi


printf "${CYAN}Copy vim config...${NOF}\n"
mkdir -p $HOME/.vim/plugin/
if [ ! -f $HOME/.vim/plugin/custom.vim ]
then
  curl -s https://raw.githubusercontent.com/She110ck/dotfiles/master/vim/plugin/custom.vim --output $HOME/.vim/plugin/custom.vim
fi

printf "${GREEN}Configuration successful!...${NOF}\n"

