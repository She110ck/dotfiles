# Introduction
My dotfiles with init script.  

## Installation
**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!  

### Using Git and the bootstrap script

Repo contains submodules for `zsh`. If you need them, clone with  `--recursive-submodules` flag.  
```bash
git clone --recurse-submodules -j8 git@github.com:She110ck/dotfiles.git

```
Depend on the goal, you need to run `bootstrap.sh` file with different flags.  
Installing requires sudo privelege. 


## Issues

## Keyboard layout indicator
The biggest issue that I had. This is the hell.  
There's **NO WAY** to find out which keyboard layout is currently active. What the hell?  

There is only one tool- `gxkb` which is defines active keyboard layout and shows on tray (still ne cli).  
And guess what? Flags are missing. 

### Bluetooth
I had a bluetooth issue when tired to connect my headphones.  
Tried to install pipewire, didn't work.  
Beside of that, I got random freezes.  
After deleting everything and reinstalling pulseaudio (also pulseaudio-bluetooth module which activates after reboot) found fix script.  
Originally found on [this post](https://www.jeremymorgan.com/tutorials/linux/how-to-bluetooth-arch-linux/) 
with [this gist](https://gist.github.com/hxss/a3eadb0cc52e58ce7743dff71b92b297).

### Markdown view
Grip can real-time render markdown file. Recommend to use in pair with `venv`.  
```
pip install grip
```


## TODO:
* i3lock
* i3 exit tray
 

## FAQ
* Why `vim` configs provided as a folder instead of `.vimrc`?  
When we creating `.vimrc`, default vim configs (with some highlighting) automatically disabled.  
We can include default configs on `.vimrc` (look at first line), or use `~/.vim/plugin/custom.vim` path.
* Same thing with tmux.

