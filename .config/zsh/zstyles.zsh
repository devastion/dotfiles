#!/usr/bin/env zsh

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group 'H' 'L'
zstyle ':fzf-tab:*' fzf-flags '--tmux' '80%'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# enhance completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache true
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME/.config/zsh}/.zcompcache"
zstyle ':completion:*' rehash true

zle_highlight=('paste:none')
