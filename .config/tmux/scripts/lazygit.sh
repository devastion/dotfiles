#!/usr/bin/env bash

PANE_CURRENT_PATH=$(tmux display -p -F "#{pane_current_path}")
GIT_ROOT_PATH=$(cd "${PANE_CURRENT_PATH}" && git rev-parse --show-toplevel)
TMUX_POPUP_WIDTH="80%"
TMUX_POPUP_HEIGHT="80%"

if [[ -z $GIT_ROOT_PATH ]]; then
  tmux display "Not in git repository"
else
  tmux popup -w $TMUX_POPUP_WIDTH -h $TMUX_POPUP_HEIGHT -E "lazygit -p ${GIT_ROOT_PATH}"
fi
