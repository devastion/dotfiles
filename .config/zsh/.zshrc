#!/usr/bin/env zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zsh settings
export HISTFILE="$ZSH_STATE_DIR/history"
export SAVEHIST=$(( 100 * 1000 ))
export HISTSIZE=$(( 1.2 * SAVEHIST ))

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
  "piotr1215/zledit"
  "zsh-users/zsh-completions"
  "michaelaquilina/zsh-you-should-use"
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


# plugin options

## zledit vi-mode
zstyle ':zledit:' disable-bindings yes
bindkey -M viins "^[j" zledit-widget
bindkey -M vicmd "J" zledit-widget

FZF_DEFAULT_OPTS="--tmux=80% \
  --layout=reverse \
  --highlight-line \
  --cycle \
  --bind=ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up \
  --color=border:#27a1b9
"
EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

## zsh-vi-mode
ZVM_VI_SURROUND_BINDKEY="s-prefix"
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_HIGHLIGHT_BACKGROUND=("paste:none")

# ohmyzsh fzf plugin
DISABLE_FZF_KEY_BINDINGS="true"

# aliases
source "$ZDOTDIR/aliases.zsh"

# styles
source "$ZDOTDIR/styles.zsh"

# options
source "$ZDOTDIR/options.zsh"

# keymaps
source "$ZDOTDIR/keymaps.zsh"

zle_highlight=('paste:none')  # Disables highlight on paste

plugins=(
  "powerlevel10k"

  "fzf-tab"
  "zsh-vi-mode"

  "zsh-defer"
  "fast-syntax-highlighting"
  "zsh-autosuggestions"
  "zsh-autopair"
  "ohmyzsh/plugins/magic-enter"
  "ohmyzsh/plugins/aliases"
  "ohmyzsh/plugins/gitignore"
  "ohmyzsh/plugins/fzf"
  "zledit"
  "zsh-you-should-use"
)
plugin-source $plugins

# zsh-vi-mode
function zvm_after_init() {
  eval "$(mise activate zsh)"
  eval "$(zoxide init zsh)"
  zsh-defer source "${ZDOTDIR:-$HOME/.config/zsh}/extras/fzf/fzf.plugin.zsh"
  eval "$(register-python-argcomplete pipx)"
}

[[ ! -f "${ZDOTDIR}/.p10k.zsh" ]] || source "${ZDOTDIR}/.p10k.zsh"
