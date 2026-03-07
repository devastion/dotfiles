#!/usr/bin/env sh

TPM_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"

if [ ! -d "${TPM_PATH}" ]; then
  git clone https://github.com/tmux-plugins/tpm "${TPM_PATH}"
fi
