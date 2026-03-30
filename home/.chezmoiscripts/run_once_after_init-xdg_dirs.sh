#!/usr/bin/env sh

# -e: exit on error
# -u: exit on unset variables
set -eu

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$HOME/.xdg}"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
LOCAL_BIN="$HOME/.local/bin"

for dir in \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_RUNTIME_DIR" \
  "$PROJECTS_DIR" \
  "$LOCAL_BIN"; do
  mkdir -p "$dir"
done

chmod 0700 "$XDG_RUNTIME_DIR"
