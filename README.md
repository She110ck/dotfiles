# Introduction
My dotfiles with init script.  

## Installation
**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!  

## Good to know
`dotfiles` will have `backup` directory in case if you already have some configs for things below. Just will move with timestap, don't worry.


Often I had a issue with nested window containers on i3wm. For example when you focusing on parent window with `Mod+a` and trying to split, but it just becomes messy. Found solution [there](https://publish.reddit.com/embed?url=https://www.reddit.com/r/i3wm/comments/enl5to/comment/feems8p/)

> A node that has either a vertical or horizontal preselected split, if you attempt to move it left or right, it clears the split instead of moving it. 

### Using Git and the bootstrap script

Repo contains submodules for `zsh`. If you need them, clone with  `--recursive-submodules` flag.  
``` bash
git clone --recurse-submodules -j8 git@github.com:She110ck/dotfiles.git

# if you want to configure your server, no need for zsh modules.
git clone git@github.com:She110ck/dotfiles.git
```
Depend on the goal, you need to run `bootstrap.sh` file with different flags.  
Some commands requires sudo privelege. 



I also have server related second configuration.

```
# server configuration
bash -c "$(curl -fsSL https://t.ly/Sxdf)"

```


## Manual config
Not everything configured automatically because of security concerns.

### Browsers
Usually I prefer install browser extensions manually. This is brief list what I usually have:
* `News Feed Eradicator` - powerful tool makes me stop wasting time
* `uBlock` - no comment
* `SponsorBlock for Youtube` - allows pass video integrated promotions. Powerful tool to avoid your distraction.
* `Pomodoro` - usually I forgetting use it, but I have.
* `Multi Account Containers` - for firefox

### DOAS - sudo alternative
Just use arch wiki. Easy enough to configure in 5 minute
### Tmux config

Using as a prefix command `C-Space`.
On first start use `C-Space I` to install plugins. Yes, capital I.

### SSH/MOSH
Here is a small example snippet how it can be look like:

``` sh
Host server-ssh
        HostName example.com
        IdentityFile ~/.ssh/some_cert
        User user
        RequestTTY yes
        # RemoteCommand tmux attach -t s1
        RemoteCommand tmux new -A -s s1 -n s1
        LocalForward 8000 localhost:8000

# mosh
Host server
        HostName example.com
        IdentityFile ~/.ssh/some_cert
        User user
        # RequestTTY yes
        # RemoteCommand tmux new -A -s s1 -n s1
        LocalForward 8000 localhost:8000
```
Mosh doesn't handle `RequestTTY` and `RemoteCommand` nor ignore them which is a shame. I have to dublicate some configs for backward compatibility with ssh.  
### Thinkpad fan and power save
Thinkpad fan controlled by `thinkfan` package which can require some customization, and power saving mode managed by `tlp` package which usually works out of box.  
You can find `thinkfan.conf` file which can be copied to `/etc/thinkfan.conf` and that it.  

Also, comment line on `/usr/lib/modprobe.d/thinkpad_acpi.conf` to run thinkfan properly.

## Issues
Some issues hardware spesific, which means you need to handle manually.

### Keyboard layout indicator
The biggest issue that I had. This is the hell.  
There's **NO WAY** to find out which keyboard layout is currently active. What the hell?  

Only this command **WHICH DOESN'T WORK IF YOU WANT TO CYCLE LAYOUTS** via win+space.  
`setxkbmap -query | grep layout | colrm 1 12`

There is only one tool- `gxkb` which is defines active keyboard layout and shows on tray (still non cli option).  
And guess what? Country flags are missing. 

### Ctrl+Shift+C issue
You know that, you faced it. Chrome opens devtools when you trying to copy something. There's no native way to disable. Only via extension.
I set up it to something without affect via `chrome://extensions/shortcuts`.
Or you can use extension to "fix" it.

### Bluetooth
I had a bluetooth issue when tired to connect my headphones.  
Tried to install pipewire, didn't work.  
Beside of that, I got random freezes.  
After deleting everything and reinstalling pulseaudio (also pulseaudio-bluetooth module which activates after reboot) found fix script.  
Originally found on [this post](https://www.jeremymorgan.com/tutorials/linux/how-to-bluetooth-arch-linux/) 
with [this gist](https://gist.github.com/hxss/a3eadb0cc52e58ce7743dff71b92b297).

### Intel/wifi dmesg error log
There's fail logs. I spent a lot of time to handle. Tried via modprobe kernel flags, didn't work.  
I found [gist with explanation](https://gist.github.com/Brainiarc7/3179144393747f35e5155fdbfd675554) what's going on, and how to fix it.
```
# disable dmesg logs:
# rtw_8822ce 0000:05:00.0: PCIe Bus Error: severity=Corrected, type=Physical Layer, (Receiver ID)
# copy .service to /etc/systemd/system/ and execute:

systemctl daemon-reload
systemctl enable fix_intel_realtek_wifi_log_sh-t.service
systemctl start fix_intel_realtek_wifi_log_sh-t.service
```

## Markdown view
Grip can real-time render markdown file. Recommend to use in pair with `venv`.  
``` bash
pip install grip
```
## Theme customizing
I prefer to see ~~how much~~ jobs on background. So I customized promt a bit on `.zshrc`.


## TODO:
[x] screenshot  
[x] photo/video viewer  
[x] bluetooth  
[x] automount (lxsession)  
[x] xautolock  
[x] i3lock  
[x] i3 exit tray  
[ ] polybar  
[x] mpd  
[x] mosh  
[x] sysstat  
[x] power saving  
[x] laptop fan  


## FAQ
**Q: Why `vim` configs provided as a folder instead of `.vimrc`?**  
 
**A:** When we creating `.vimrc`, default vim configs (with some highlighting) automatically disabled. 
 We can include default configs on `.vimrc` (look at first line), or use `~/.vim/plugin/custom.vim` path.  
 
**Q: What about tmux?**  
 
**A:** Same thing with tmux.

**Q: Where I can find Nerd Font icons?**

**A:** Check this out: [https://www.nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet)

**Q: How to sync time on linux?**

**A:** First you need to update your OS time via ntp. Second, you need sync hardware clock with it. 
```
sudo timedatectl set-ntp true
sudo hwclock --systohc 

```

