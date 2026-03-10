#!/usr/bin/env zsh

# history
setopt \
  extended_history \
  hist_expire_dups_first \
  hist_find_no_dups \
  hist_ignore_all_dups \
  hist_ignore_space \
  hist_no_store \
  hist_reduce_blanks \
  hist_save_no_dups \
  hist_verify \
  inc_append_history \
  share_history \
  hist_fcntl_lock

# completion
setopt \
complete_in_word \
always_to_end \
auto_param_slash \
no_complete_aliases \
auto_list \
auto_menu

# jobs
setopt long_list_jobs
unsetopt auto_resume
setopt notify
unsetopt bg_nice

# other
setopt auto_cd
setopt auto_pushd
setopt bang_hist
setopt interactive_comments
setopt multios
setopt no_beep
setopt prompt_subst
setopt pushd_ignore_dups
setopt pushd_minus
setopt globdots
setopt extendedglob
unsetopt correct
setopt noclobber
setopt globstarshort
setopt numericglobsort
setopt no_nomatch

