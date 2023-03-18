# Introduction
My dotfiles with init script.  


## Issues

### Bluetooth
I had a bluetooth issue when tired to connect my headphones.  
Tried to install pipewire, didn't work.  
Beside of that, I got random freezes.  
After deleting everything and reinstalling pulseaudio (also pulseaudio-bluetooth module which activates after reboot) found fix script.  
Originally found on [this post](https://www.jeremymorgan.com/tutorials/linux/how-to-bluetooth-arch-linux/) 
with [this gist](https://gist.github.com/hxss/a3eadb0cc52e58ce7743dff71b92b297).

### Markdown view
Grip can real-time render markdown file. Recommend to use in pair with `venv`.  
`pip install grip`


## TODO:
* i3lock
* i3 exit tray
 

## FAQ
* Why `vim` configs provided as a folder instead of `.vimrc`?  
When we creating `.vimrc`, default vim configs (with some highlighting) automatically disabled.  
We can include default configs on `.vimrc` (look at first line), or use `~/.vim/plugin/custom.vim` path.
* Same thing with tmux.

