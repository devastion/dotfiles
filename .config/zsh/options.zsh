#/usr/bin/env zsh

# history options
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
setopt hist_fcntl_lock        # modern file locking

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
