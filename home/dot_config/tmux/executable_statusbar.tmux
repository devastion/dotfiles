#!/usr/bin/env bash

tmux set -g status-right "%d-%m-%Y %H:%M #{?mouse,#[fg="#30363f" bold#,bg="#e55561"],#[fg="#30363f" bold#,bg="#8ebd6b"]} M "
tmux set -g status-left "#{tmux_mode_indicator}"
tmux set -g status-left-length 30
tmux set -g status-right-length 30
tmux set -g status-justify "centre"
tmux set -g status-bg "#1A1B26"
tmux set -g status-fg "#A9B1D6"
tmux set -g status-position "top"
tmux set -g window-status-format "  #I:#W  "
tmux set -g window-status-current-style bg="#1A1B26",fg="#7DCFFF",bold
tmux set -g window-status-current-format "  #I:#W  "
tmux set -g message-style bg="#7aa2f7",fg="#24283b"
tmux set -g message-command-style fg="#7aa2f7",bg="#24283b"
