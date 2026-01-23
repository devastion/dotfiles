#!/usr/bin/env bash

export LANGUAGE="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export WORDCHARS="*?_-.[]~&;!#$%^(){}<>-"
export PAGER="less"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

eval "$(mise activate bash)"
