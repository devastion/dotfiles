#!/usr/bin/env zsh

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

# paths without duplicates
typeset -gU path fpath cdpath

if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

path=(
  "${HOME}/.local/bin"
  $path
)

if [[ -d "$XDG_DATA_HOME/shell/functions" ]]; then
  fpath+=("${XDG_DATA_HOME}/shell/functions")
fi

if [[ -d "$ZDOTDIR/functions" ]]; then
  fpath+=("${ZDOTDIR}/functions")
fi

if [[ -d "$ZDOTDIR/completions" ]]; then
  fpath+=("${ZDOTDIR}/completions")
fi

cdpath=(
  "${XDG_PROJECTS_DIR:-HOME/Projects}"
  $cdpath
)
