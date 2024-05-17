#!/bin/zsh

# XDG
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$HOME/.xdg}
export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}

() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
  done
} XDG_{CONFIG,CACHE,DATA,STATE}_HOME XDG_{RUNTIME,PROJECTS}_DIR

# zsh
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
export ZPLUGINDIR="${ZPLUGINDIR:-$ZDOTDIR/plugins}"

# zim - zsh plugin manager
export ZIM_HOME="${ZIM_HOME:-$XDG_CACHE_HOME/zim}"
export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-$ZDOTDIR/.zimrc}"

