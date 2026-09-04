#!/usr/bin/env zsh

zmodload -m -F zsh/files 'b:zf_*'

setopt extended_history
setopt hist_allow_clobber
setopt hist_expire_dups_first
setopt hist_fcntl_lock
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt share_history # or inc_append_history_time

setopt no_bang_hist
setopt no_hist_beep

typeset HISTFILE="${ZSH_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/zsh}/history"
[[ -d ${HISTFILE:h} ]] || zf_mkdir -p "${HISTFILE:h}"
typeset -i HISTSIZE=100000
typeset -i SAVEHIST=20000
typeset HISTORY_IGNORE='(rm *|cd#( *)#|..|pushd#( *)#|popd#( *)#|l[alsh]#( *)#|pwd|exit|*sudo -S*|(n|)vi(m|)( *)#)'
