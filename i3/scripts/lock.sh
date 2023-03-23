#!/usr/bin/env sh

# https://github.com/Raymo111/i3lock-color/blob/master/examples/lock.sh

setxkbmap -layout us

i3lock --nofork -B 10 \
--ringcolor=DFE2E5FF \
--insidevercolor=95AEC7A0 \
--keyhlcolor=393F45FF \
--verifcolor=95AEC7FF \
--wrongcolor=C795AEFF

