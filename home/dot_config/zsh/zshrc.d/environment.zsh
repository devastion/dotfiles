#!/usr/bin/env zsh

typeset -U cdpath fpath manpath

fpath=(
  "${ZSH_FUNCTIONS_DIR:-$ZDOTDIR/functions}"(-/NF)
  "${ZSH_COMPLETIONS_DIR:-$HOME/.local/share/zsh/site-functions}"(-/NF)
  "$HOMEBREW_PREFIX/share/zsh/functions"(-/NF)
  "$HOMEBREW_PREFIX/share/zsh/site-functions"(-/NF)
  "$HOME/.orbstack/shell/completions/zsh"(-/NF)
  $fpath
)

manpath=(
  "$HOMEBREW_PREFIX/share/man"(-/NF)
  "$HOMEBREW_PREFIX/opt/"{coreutils,ed,findutils,gawk,gnu-indent,gnu-sed,gnu-tar,gnu-which,grep,make}/libexec/gnuman(-/NF)
  $manpath
)

cdpath=(
  "$HOME"(-/NF)
  $cdpath
)

if [[ -n $HOMEBREW_PREFIX && -d $HOMEBREW_PREFIX/share/zsh/help ]]; then
  typeset -x HELPDIR="$HOMEBREW_PREFIX/share/zsh/help"
elif [[ -d "/usr/share/zsh/$ZSH_VERSION/help" ]]; then
  typeset -x HELPDIR="/usr/share/zsh/$ZSH_VERSION/help"
else
  unset HELPDIR
fi

# zsh-autosuggestions
typeset -x ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
typeset -x ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
typeset -a _git_ignore=(
  'add *'
  'ci *'
  'commit -m *'
  'checkout -b *'
)
typeset -a _autosuggest_ignore=(
  "(g|git) (${(j:|:)_git_ignore})"
  '(ls|lsa) *'
  '(cp|mv) *'
)

typeset -x ZSH_AUTOSUGGEST_HISTORY_IGNORE="(${(j:|:)_autosuggest_ignore})"
typeset -x ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
unset _git_ignore _autosuggest_ignore
