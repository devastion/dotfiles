#!/usr/bin/env zsh

# zsh directories
## xdg base dirs (fallbacks)
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

export ZSH_DATA_DIR="$XDG_DATA_HOME/zsh"
export ZSH_STATE_DIR="$XDG_STATE_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export ZCOMPDUMP="$ZSH_CACHE_DIR/zcompdump"
export ZCOMPCACHE="$ZSH_CACHE_DIR/zcompcache"
export ZPLUGINDIR="$ZSH_DATA_DIR/plugins"

## ensure dirs exist
mkdir -p \
  "$ZSH_DATA_DIR" \
  "$ZSH_STATE_DIR" \
  "$ZSH_CACHE_DIR"

# system settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_COLLATE="C"
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export WORDCHARS='*?_-.[]~&;!#$%^(){}<>-'
export PAGER="less"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LESSOPEN='| lessfilter %s'

# paths without duplicates
typeset -gU path fpath cdpath

if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

path+=(
  "${HOME}/.local/bin"
)

if [[ -d "$XDG_DATA_HOME/shell/functions" ]]; then
  fpath+=("$XDG_DATA_HOME/shell/functions")
fi

if [[ -d "$ZDOTDIR/functions" ]]; then
  fpath+=("$ZDOTDIR/functions")
fi

if [[ -d "$ZDOTDIR/completions" ]]; then
  fpath+=("$ZDOTDIR/completions")
fi

cdpath+=(
  "${XDG_PROJECTS_DIR:-HOME/Projects}"
)
