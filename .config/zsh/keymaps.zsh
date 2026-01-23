#/usr/bin/env zsh

# normal mode
bindkey -M vicmd "/" fzf-history-widget

# insert mode
bindkey -M viins "^a" beginning-of-line
bindkey -M viins "^e" end-of-line
bindkey -M viins "^f" forward-char
bindkey -M viins "^b" backward-char
bindkey -M viins "^[f" forward-word
bindkey -M viins "^[b" backward-word
bindkey -M viins "^w" backward-kill-word
bindkey -M viins "^[d" kill-word
bindkey -M viins "^[^?" backward-kill-word
