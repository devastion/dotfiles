#!/usr/bin/env zsh

ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

autoload -U compinit; compinit
autoload -Uz ${ZDOTDIR}/functions/*(:t)

repos=(
  "romkatv/powerlevel10k"

  "Aloxaf/fzf-tab"
  "zsh-users/zsh-autosuggestions"
  "hlissner/zsh-autopair"
  "jeffreytse/zsh-vi-mode"

  "romkatv/zsh-defer"
  "zdharma-continuum/fast-syntax-highlighting"
  "olets/zsh-abbr"
)

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache true
zstyle ':completion::complete:*' cache-path "${ZDOTDIR}/.zcompcache"
zstyle ':completion:*' rehash true

# enhance completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'

# variables
export FZF_DEFAULT_OPTS="--tmux=80% --layout=reverse --highlight-line --cycle --bind=ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up"
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZVM_VI_SURROUND_BINDKEY="s-prefix"
export ZVM_SYSTEM_CLIPBOARD_ENABLED=true
export ZVM_VI_HIGHLIGHT_BACKGROUND=("paste:none")
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"
export ABBR_USER_ABBREVIATIONS_FILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh-abbr"

# aliases
alias l="eza --git"
alias ll="l -lao --group-directories-first"
alias ld="l -lD"
alias lf="l -lf"
alias lh="l -ld .* --group-directories-first"
alias lt="l -la --sort=modified --reverse"
alias ls="ll --grid"

alias "cd.."="cd_up"

# Replaced with zsh-abbr
# alias pbc="pbcopy"
# alias pbp="pbpaste"
# alias nr="npm run"
# alias dco="docker compose"

alias nvim="mise x node@latest -- nvim"

# history options
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${ZDOTDIR}/.zsh_history"
setopt append_history         # Allow multiple sessions to append to one Zsh command history.
setopt extended_history       # Show timestamp in history.
setopt hist_expire_dups_first # Expire A duplicate event first when trimming history.
setopt hist_find_no_dups      # Do not display a previously found event.
setopt hist_ignore_all_dups   # Remove older duplicate entries from history.
setopt hist_ignore_dups       # Do not record an event that was just recorded again.
setopt hist_ignore_space      # Do not record an Event Starting With A Space.
setopt hist_reduce_blanks     # Remove superfluous blanks from history items.
setopt hist_save_no_dups      # Do not write a duplicate event to the history file.
setopt hist_verify            # Do not execute immediately upon history expansion.
setopt inc_append_history     # Write to the history file immediately, not when the shell exits.
setopt share_history          # Share history between different instances of the shell.

# other
setopt auto_cd                # Use cd by typing directory name if it's not a command.
setopt auto_list              # Automatically list choices on ambiguous completion.
setopt auto_pushd             # Make cd push the old directory onto the directory stack.
setopt bang_hist              # Treat the '!' character, especially during Expansion.
setopt interactive_comments   # Comments even in interactive shells.
setopt multios                # Implicit tees or cats when multiple redirections are attempted.
setopt no_beep                # Don't beep on error.
setopt prompt_subst           # Substitution of parameters inside the prompt each time the prompt is drawn.
setopt pushd_ignore_dups      # Don't push multiple copies directory onto the directory stack.
setopt pushd_minus            # Swap the meaning of cd +1 and cd -1 to the opposite.

zle_highlight=('paste:none')  # Disables highlight on paste

plugin-load $repos

[[ ! -f "${ZDOTDIR}/.p10k.zsh" ]] || source "${ZDOTDIR}/.p10k.zsh"

# zsh-vi-mode
function zvm_after_init() {
  eval "$(mise activate zsh)"
  eval "$(zoxide init zsh)"

  FZF_ALT_C_COMMAND= FZF_CTRL_T_COMMAND= source <(fzf --zsh)

  # normal mode
  zvm_bindkey vicmd "/" fzf-history-widget

  # insert mode
  zvm_bindkey viins "^a" beginning-of-line
  zvm_bindkey viins "^e" end-of-line
  zvm_bindkey viins "^f" forward-char
  zvm_bindkey viins "^b" backward-char
  zvm_bindkey viins "^[f" forward-word
  zvm_bindkey viins "^[b" backward-word
  zvm_bindkey viins "^w" backward-kill-word
  zvm_bindkey viins "^[d" kill-word
  zvm_bindkey viins "^[^?" backward-kill-word
}
