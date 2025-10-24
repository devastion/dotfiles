#!/usr/bin/env bash

tmux list-windows -F '#I:#W' |
  awk 'BEGIN {ORS=" "} {split($1,a,":"); print a[2], NR, "\"select-window -t", a[1] "\""}' |
  xargs tmux display-menu -T "Switch-window"
