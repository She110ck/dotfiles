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

printf "${CYAN}Copy vim config...${NOF}\n"
mkdir -p $HOME/.vim/plugin/
if [ ! -f $HOME/.vim/plugin/custom.vim ]
then
  curl -s https://raw.githubusercontent.com/She110ck/dotfiles/master/vim/plugin/custom.vim --output $HOME/.vim/plugin/custom.vim
fi

printf "${GREEN}Configuration successful!...${NOF}\n"

