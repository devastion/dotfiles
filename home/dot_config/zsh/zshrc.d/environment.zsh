#!/usr/bin/env zsh

if [[ $OSTYPE != darwin* ]]; then
  if (($+commands[wl-copy])); then
    alias pbcopy='command wl-copy'
    alias pbpaste='command wl-paste'
  elif (($+commands[xclip])); then
    alias pbcopy='command xclip -selection clipboard'
    alias pbpaste='command xclip -selection clipboard -o'
  elif (($+commands[clip.exe])); then
    alias pbcopy='command clip.exe'
    alias pbpaste='command powershell.exe -command Get-Clipboard'
  fi
fi

# Update `$EDITOR` and `$MANPAGER` variable
if (($+commands[nvim])); then
  typeset -x EDITOR='nvim'
  typeset -x MANPAGER='nvim +Man!'
elif (($+commands[vim])); then
  typeset -x EDITOR='vim'
fi
typeset -x VISUAL="$EDITOR"

# Colorful output of CLI programs
typeset -x -i CLICOLOR=1

# Settings for `less` pager
if (($+commands[lessfilter])); then
  typeset -x LESSOPEN='| lessfilter %s'
elif (($+commands[lesspipe])); then
  typeset -x LESSOPEN='| lesspipe %s'
elif (($+commands[lesspipe.sh])); then
  typeset -x LESSOPEN='| lesspipe.sh %s'
else
  unset LESSOPEN
fi

# Colorful manpages for `less` pager
if [[ -t 1 && -n $TERM && $TERM != 'dumb' ]] && (($+commands[tput])); then
  typeset -x LESS_TERMCAP_mb=$(tput blink setaf 4)
  typeset -x LESS_TERMCAP_md=$(tput bold setaf 4)
  typeset -x LESS_TERMCAP_me=$(tput sgr0)
  typeset -x LESS_TERMCAP_se=$(tput sgr0)
  typeset -x LESS_TERMCAP_so=$(tput rev)
  typeset -x LESS_TERMCAP_ue=$(tput sgr0)
  typeset -x LESS_TERMCAP_us=$(tput smul setaf 5)
fi

# Use Homebrew's helpdir for zsh (make sure to use `chsh -s /opt/homebrew/bin/zsh`)
if [[ -n $HOMEBREW_PREFIX && -d $HOMEBREW_PREFIX/share/zsh/help ]]; then
  typeset -x HELPDIR="$HOMEBREW_PREFIX/share/zsh/help"
elif [[ -r "/usr/share/zsh/$ZSH_VERSION/help/run-help" ]]; then
  typeset -x HELPDIR="/usr/share/zsh/$ZSH_VERSION/help"
else
  unset HELPDIR
fi

# FZF variables and settings
typeset -x FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/config"

typeset _fzf_history="${XDG_STATE_HOME:-$HOME/.local/state}/fzf/history"
zmodload -m -F zsh/files 'b:zf_*'
[[ -d ${_fzf_history:h} ]] || zf_mkdir -p -- "${_fzf_history:h}"
typeset -x FZF_DEFAULT_OPTS="--history ${(q)_fzf_history}"
unset _fzf_history

(($+commands[fd])) && {
  typeset -x FZF_DEFAULT_COMMAND='command fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'
  typeset -x FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  typeset -x FZF_ALT_C_COMMAND='command fd --type d --hidden --follow --strip-cwd-prefix --exclude .git'
}

typeset -x FZF_CTRL_T_OPTS="
--multi
--bind 'ctrl-o:execute(nvim {+})+abort'
--header 'CTRL-O open in neovim'
"
typeset -x FZF_CTRL_R_OPTS="
--preview 'printf %s {2..}'
--preview-window=down:3:wrap:hidden,border-up
--bind 'ctrl-y:execute-silent(printf %s {2..} | pbcopy)+abort'
--color header:italic
--header 'CTRL-Y copy · ? preview · CTRL-R toggle sort'
"

(($+commands[rg])) && _fzf_compgen_path() {
  command rg --files --glob '!.git' "$1"
}

(($+commands[fd])) && _fzf_compgen_dir() {
  command fd --type d --hidden --follow --exclude '.git' "$1"
}

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

# Setup `cdpath`, `fpath` and `manpath`
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
  $manpath
)

cdpath=(
  "$HOME"(-/NF)
  $cdpath
)
