#!/usr/bin/env zsh

# system settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_COLLATE="C"
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export WORDCHARS="*?_-.[]~&;!#$%^(){}<>-"
export PAGER="less"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# paths without duplicates
typeset -gU path fpath cdpath

path=(
  "${HOME}/.local/bin"
  $path
)

fpath=(
  "${ZDOTDIR}/functions"
  "${ZDOTDIR}/completions"
  $fpath
)

cdpath=(
  "${HOME}/Projects"
  $cdpath
)

eval "$(mise activate zsh --shims)"
