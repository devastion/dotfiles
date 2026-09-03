#!/usr/bin/env zsh

# History
# setopt extended_history
# setopt hist_allow_clobber
# setopt hist_expire_dups_first
# setopt hist_fcntl_lock
# setopt hist_find_no_dups
# setopt hist_ignore_all_dups
# setopt hist_ignore_space
# setopt hist_no_functions
# setopt hist_no_store
# setopt hist_reduce_blanks
# setopt hist_save_no_dups
# setopt hist_verify
# setopt share_history # or inc_append_history_time

# setopt no_bang_hist
# setopt no_hist_beep

# Changing Directories
setopt auto_cd
setopt auto_pushd
setopt cd_silent
setopt cdable_vars
setopt pushd_ignore_dups
setopt pushd_minus
setopt pushd_silent
setopt pushd_to_home

# Completion
# setopt always_to_end
# setopt auto_list
# setopt auto_param_keys
# setopt auto_param_slash
# setopt complete_in_word
# setopt list_types

# setopt no_list_beep

# Expansion & Globbing
setopt extended_glob
setopt numeric_glob_sort

setopt no_glob_dots # (use *(D) instead)
setopt no_ignore_braces
setopt no_nomatch
setopt no_null_glob

# Input/Output
setopt hash_cmds
setopt hash_dirs
setopt ignore_eof
setopt interactive_comments
setopt no_rm_star_silent
setopt path_dirs
setopt path_script
setopt rc_quotes
setopt rm_star_wait
setopt short_loops

setopt no_clobber
setopt no_correct
setopt no_correct_all
setopt no_flow_control
setopt no_mail_warning

# Job Control
setopt auto_resume
setopt long_list_jobs
if [[ -o interactive && -t 1 ]]; then
  setopt monitor
  setopt notify
fi

setopt no_bg_nice
setopt no_check_jobs
setopt no_hup

# Prompting
# setopt prompt_subst
# setopt transient_rprompt

# Scripts and Functions
setopt function_argzero
setopt multios
setopt typeset_to_unset

# ZLE
# setopt combining_chars
# setopt vi

# setopt no_beep
