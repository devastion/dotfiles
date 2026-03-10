#!/usr/bin/env zsh

zmodload zsh/terminfo
typeset -gA key_info

# Modifiers
key_info=(
  'Control' '^'
  'Escape' '\e'
  'Meta' '^['
)

# Basic keys
key_info+=(
  'Backspace' "^?"
  'Delete' "^[[3~"
  'F1' "$terminfo[kf1]"
  'F2' "$terminfo[kf2]"
  'F3' "$terminfo[kf3]"
  'F4' "$terminfo[kf4]"
  'F5' "$terminfo[kf5]"
  'F6' "$terminfo[kf6]"
  'F7' "$terminfo[kf7]"
  'F8' "$terminfo[kf8]"
  'F9' "$terminfo[kf9]"
  'F10' "$terminfo[kf10]"
  'F11' "$terminfo[kf11]"
  'F12' "$terminfo[kf12]"
  'Insert' "$terminfo[kich1]"
  'Home' "$terminfo[khome]"
  'PageUp' "$terminfo[kpp]"
  'End' "$terminfo[kend]"
  'PageDown' "$terminfo[knp]"
  'Up' "$terminfo[kcuu1]"
  'Left' "$terminfo[kcub1]"
  'Down' "$terminfo[kcud1]"
  'Right' "$terminfo[kcuf1]"
  'BackTab' "$terminfo[kcbt]"
)

# Mod plus another key
key_info+=(
  'AltLeft' "${key_info[Escape]}${key_info[Left]} \e[1;3D"
  'AltRight' "${key_info[Escape]}${key_info[Right]} \e[1;3C"
  'ControlLeft' '\e[1;5D \e[5D \e\e[D \eOd'
  'ControlRight' '\e[1;5C \e[5C \e\e[C \eOc'
  'ControlPageUp' '\e[5;5~'
  'ControlPageDown' '\e[6;5~'
)

local -A viins_keybinds
viins_keybinds=(
  "$key_info[Control]A" beginning-of-line
  "$key_info[Control]E" end-of-line
  "$key_info[Control]a" beginning-of-line
  "$key_info[Control]e" end-of-line
  "$key_info[Control]f" forward-char
  "$key_info[Control]b" backward-char
  "$key_info[Meta]f" forward-word
  "$key_info[Meta]b" backward-word
  "$key_info[Control]w" backward-kill-word
  "$key_info[Meta]d" kill-word
  "$key_info[Meta]$key_info[Backspace]" backward-kill-word
  "$key_info[Up]" history-substring-search-up
  "$key_info[Down]" history-substring-search-down
  "$key_info[Control]p" history-substring-search-up
  "$key_info[Control]n" history-substring-search-down
  "$key_info[Control]r" fzf-history-widget
  "$key_info[Meta]e" zledit-widget
)

for key widget in ${(kv)viins_keybinds}; do
  bindkey -M viins "$key" "$widget"
done

local -A vicmd_keybinds
vicmd_keybinds=(
  "$key_info[Control]r" redo
  "k" history-substring-search-up
  "j" history-substring-search-down
  "/" fzf-history-widget
  "$key_info[Meta]e" zledit-widget
)

for key widget in ${(kv)vicmd_keybinds}; do
  bindkey -M vicmd "$key" "$widget"
done
