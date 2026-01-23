#!/usr/bin/env zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "${ZDOTDIR:-$HOME/.config/zsh}/zsh_unplugged.zsh"

repos=(
  "romkatv/powerlevel10k"

  "aloxaf/fzf-tab"
  "jeffreytse/zsh-vi-mode"

  "romkatv/zsh-defer"
  "ohmyzsh/ohmyzsh"
  "zdharma-continuum/fast-syntax-highlighting"
  "zsh-users/zsh-autosuggestions"
  "hlissner/zsh-autopair"
  "jimhester/per-directory-history"
  "piotr1215/zledit"
  "olets/zsh-abbr"
  "zsh-users/zsh-completions"
)
plugin-clone $repos

plugin-source "zsh-completions"

# Load the prompt system and completion system and initilize them
autoload -Uz compinit promptinit

# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
_comp_files=($ZCOMPDUMP(Nm-20))
if (( $#_comp_files )); then
    compinit -i -C -d "$ZCOMPDUMP"
else
    compinit -i -d "$ZCOMPDUMP"
fi
unset _comp_files
promptinit

if [[ -d "$ZDOTDIR/functions" ]]; then
  autoload -Uz ${ZDOTDIR}/functions/*(:t)
fi

if [[ -d "$XDG_DATA_HOME/shell/functions" ]]; then
  autoload -Uz ${XDG_DATA_HOME}/shell/functions/*(:t)
fi


# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache true
zstyle ':completion::complete:*' cache-path "$ZCOMPCACHE"
zstyle ':completion:*' rehash true

# enhance completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no

# fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview \
  'HOMEBREW_COLOR=1 brew info $word'
zstyle ':fzf-tab:complete:tldr:*' fzf-preview 'tldr --color always $word'
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'
zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help $word'
zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word'

# zledit vi-mode
zstyle ':zledit:' disable-bindings yes
bindkey -M viins "^[j" zledit-widget
bindkey -M vicmd "J" zledit-widget

# variables
export FZF_DEFAULT_OPTS="--tmux=80% \
  --layout=reverse \
  --highlight-line \
  --cycle \
  --bind=ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up \
  --color=border:#27a1b9
"
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZVM_VI_SURROUND_BINDKEY="s-prefix"
export ZVM_SYSTEM_CLIPBOARD_ENABLED=true
export ZVM_VI_HIGHLIGHT_BACKGROUND=("paste:none")
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"
export ABBR_USER_ABBREVIATIONS_FILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh-abbr"
export HISTORY_BASE="$ZSH_STATE_DIR/per_directory_history"
export HISTORY_START_WITH_GLOBAL=false
export PER_DIRECTORY_HISTORY_TOGGLE="^H"

# aliases
if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
  function unquarantine() {
    for attribute in com.apple.metadata:kMDItemDownloadedDate com.apple.metadata:kMDItemWhereFroms com.apple.quarantine; do
      xattr -r -d "$attribute" "$@"
    done
  }
fi

alias l="eza --git"
alias ll="l -lao --group-directories-first"
alias ld="l -lD"
alias lf="l -lf"
alias lh="l -ld .* --group-directories-first"
alias lt="l -la --sort=modified --reverse"
alias ls="ll"
alias lsg="l -ao --group-directories-first --grid"

alias q="exit"

alias mypw="pwgen -c -n -s -y 26 -1"
alias ndate="date \"+%d-%m-%y\""
# easy reload of zsh stuff
alias rl="reset && exec zsh -l"

alias "cd.."="cd_up"

# Replaced with zsh-abbr
# alias pbc="pbcopy"
# alias pbp="pbpaste"
# alias nr="npm run"
# alias dco="docker compose"

alias vim="nvim"

# history options
export HISTFILE="$ZSH_STATE_DIR/history"
export HISTSIZE=100000
export SAVEHIST=100000
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

# jobs
setopt long_list_jobs         # List jobs in the long format by default.
setopt auto_resume            # Attempt to resume existing job before creating a new process.
setopt notify                 # Report status of background jobs immediately.
unsetopt bg_nice              # Don't run all background jobs at a lower priority.
unsetopt hup                  # Don't kill jobs on shell exit.

# completion
setopt complete_in_word       # Complete from both ends of a word.
setopt always_to_end          # Move cursor to the end of a completed word.
setopt path_dirs              # Perform path search even on command names with slashes.
setopt auto_menu              # Show completion menu on a successive tab press.
setopt auto_list              # Automatically list choices on ambiguous completion.
setopt auto_param_slash       # If completed parameter is a directory, add a trailing slash.
setopt no_complete_aliases
setopt menu_complete          # Do not autoselect the first completion entry.
unsetopt flow_control         # Disable start/stop characters in shell editor.

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
setopt globdots               # Glob dotfiles as well
setopt extendedglob           # Use extended globbing
setopt correct                # Turn on correction

zle_highlight=('paste:none')  # Disables highlight on paste

plugins=(
  "powerlevel10k"

  "fzf-tab"
  "zsh-vi-mode"

  "zsh-defer"
  "fast-syntax-highlighting"
  "ohmyzsh/plugins/magic-enter"
  "zsh-autosuggestions"
  "zsh-autopair"
  "per-directory-history"
  "zledit"
  "zsh-abbr"
)
plugin-source $plugins

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

  source "${ZDOTDIR:-$HOME/.config/zsh}/fzf_lua.zsh"
  eval "$(register-python-argcomplete pipx)"
}
