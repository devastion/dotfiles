#!/usr/bin/env bash

set -euo pipefail

toggleterm_session_name="__toggleterm"
current_session_name=$(tmux display-message -p "#{session_name}")
current_window_name=$(tmux display-message -p "#{window_name}")
toggleterm_window_name="${current_session_name}.${current_window_name}"

if [ "$current_session_name" = "__toggleterm" ]; then
  tmux detach
else
  pane_current_path=$(tmux display-message -p "#{pane_current_path}")
  tmux popup -w 75% -h 75% -E "tmux new-session -A -s ${toggleterm_session_name} -c ${pane_current_path} -n ${toggleterm_window_name} \; new-window -S -n ${toggleterm_window_name} -c ${pane_current_path} \; set-option -w status off"
fi
