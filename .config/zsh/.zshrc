#!/usr/bin/env zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
  # homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

source "${ZDOTDIR:-$HOME/.config/zsh}/zsh_unplugged.zsh"

autoload -U compinit; compinit
autoload -Uz ${ZDOTDIR:-$HOME/.config/zsh}/functions/*(:t)

# list of github plugin repos
typeset -U zsh_plugin_repos=(
  romkatv/powerlevel10k
  aloxaf/fzf-tab
  devastion/zsh-vi-mode

  # deferred
  romkatv/zsh-defer
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  olets/zsh-autosuggestions-abbreviations-strategy
  hlissner/zsh-autopair
  olets/zsh-abbr
)

# tool variables
export FZF_DEFAULT_OPTS="--tmux=80% --layout=reverse --highlight-line --cycle --bind=ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up"
export ZVM_VI_SURROUND_BINDKEY="s-prefix"
export ABBR_USER_ABBREVIATIONS_FILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh-abbr"
export ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"

# load plugins
plugin-load $zsh_plugin_repos

zsh-defer source "${ZDOTDIR:-$HOME/.config/zsh}/zstyles.zsh"
zsh-defer source "${ZDOTDIR:-$HOME/.config/zsh}/options.zsh"
zsh-defer source "${ZDOTDIR:-$HOME/.config/zsh}/aliases.zsh"

function zvm_after_init() {
  FZF_ALT_C_COMMAND= FZF_CTRL_T_COMMAND= source <(fzf --zsh)
}

function zvm_after_lazy_keybindings() {
  bindkey -M vicmd "^M" autosuggest-execute
  bindkey -M vicmd "/" fzf-history-widget
}

[[ ! -f "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh" ]] || source "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh"

eval "$(${HOME}/.local/bin/mise activate zsh --shims)"
zsh-defer eval "$(zoxide init zsh)"
