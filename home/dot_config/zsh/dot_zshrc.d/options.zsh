#!/usr/bin/env zsh

# history
setopt \
  share_history \
  extended_history \
  hist_expire_dups_first \
  hist_find_no_dups \
  hist_ignore_dups \
  hist_ignore_all_dups \
  hist_save_no_dups \
  hist_ignore_space \
  hist_no_store \
  hist_reduce_blanks \
  hist_verify \
  hist_fcntl_lock

unsetopt share_history hist_beep

# completion
setopt \
  complete_in_word \
  always_to_end \
  auto_param_slash \
  no_complete_aliases \
  auto_list \
  auto_menu

# jobs
setopt long_list_jobs notify
unsetopt auto_resume bg_nice

# directory navigation
setopt \
  auto_cd \
  auto_pushd \
  pushd_ignore_dups \
  pushd_minus \
  pushd_silent

# globbing
setopt \
  glob_dots \
  extended_glob \
  glob_star_short \
  numeric_glob_sort \
  no_nomatch

# I/O & interaction
setopt \
  bang_hist \
  combining_chars \
  interactive_comments \
  multios \
  no_beep \
  no_clobber \
  prompt_subst

unsetopt correct rm_star_silent
