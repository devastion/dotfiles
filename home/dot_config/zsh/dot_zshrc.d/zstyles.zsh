#!/usr/bin/env zsh

# completion
zstyle ":completion::complete:*" use-cache true
zstyle ":completion::complete:*" cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ":completion:*" rehash true
zstyle ":completion:*" matcher-list \
  "m:{a-zA-Z}={A-Za-z}" \
  "r:|[._-]=* r:|=*" \
  "l:|=* r:|=*"
if [[ -n "${LS_COLORS:-}" ]]; then
  zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
fi
zstyle ":completion:*:descriptions" format "[%d]"
zstyle ":completion:*" menu no
zstyle ":completion:*:functions" ignored-patterns "(_*|pre(cmd|exec))"
zstyle ":completion:*:git-checkout:*" sort false
zstyle ":completion:*" squeeze-slashes true
zstyle ":completion:*:approximate:*" max-errors 2 numeric
zstyle ":completion:*:hosts" hosts off

# zledit
zstyle ":zledit:" disable-bindings yes

# fzf-tab
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview \
  'HOMEBREW_COLOR=1 brew info $word'
zstyle ':fzf-tab:complete:tldr:*' fzf-preview 'tldr --color always $word'
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'
zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help $word'
zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
  'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
"commit tag") git show --color=always $word ;;
*) git show --color=always $word | delta ;;
esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
"modified file") git diff $word | delta ;;
"recent commit object name") git show --color=always $word | delta ;;
*) git log --color=always $word ;;
esac'
zstyle ':fzf-tab:complete:mise:*' fzf-preview
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
