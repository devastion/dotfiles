#!/usr/bin/env zsh

# changing directories
setopt auto_cd                  # if a command isn't valid, but is a directory, cd to that dir
setopt auto_pushd               # make cd push the old directory onto the directory stack
setopt pushd_ignore_dups        # don’t push multiple copies of the same directory onto the directory stack
setopt pushd_minus              # exchanges the meanings of ‘+’ and ‘-’ when specifying a directory in the stack

# completions
setopt complete_in_word         # complete from both ends of a word.
setopt always_to_end            # move cursor to the end of a completed word.
setopt auto_menu                # show completion menu on a successive tab press.
setopt auto_list                # automatically list choices on ambiguous completion.
setopt auto_param_slash         # if completed parameter is a directory, add a trailing slash.
setopt extended_glob            # needed for file modification glob modifiers with compinit

# history
setopt bang_hist                # treat the '!' character specially during expansion.
setopt extended_history         # write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first   # expire a duplicate event first when trimming history.
setopt hist_ignore_dups         # do not record an event that was just recorded again.
setopt hist_ignore_all_dups     # delete an old recorded event if a new event is a duplicate.
setopt hist_find_no_dups        # do not display a previously found event.
setopt hist_ignore_space        # do not record an event starting with a space.
setopt hist_save_no_dups        # do not write a duplicate event to the history file.
setopt hist_no_store            # don't store history command
setopt hist_verify              # do not execute immediately upon history expansion.
setopt share_history            # share history between all sessions
unsetopt hist_beep              # beep when accessing non-existent history.
unsetopt inc_append_history     # write to the history file immediately, not when the shell exits.

# job control
setopt auto_resume              # attempt to resume existing job before creating a new process
setopt long_list_jobs           # list jobs in the long format by default
setopt notify                   # report status of background jobs immediately
unsetopt bg_nice                # don't run all background jobs at a lower priority
unsetopt check_jobs             # don't report on jobs when shell exit
unsetopt hup                    # don't kill jobs on shell exit

# other
unsetopt beep

histsize=10000                  # the maximum number of events to save in the internal history.
savehist=10000                  # the maximum number of events to save in the history file.
