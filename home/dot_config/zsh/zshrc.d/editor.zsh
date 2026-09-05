#!/usr/bin/env zsh

setopt combining_chars
setopt no_beep

bindkey -v
typeset -x KEYTIMEOUT=1

zmodload zsh/terminfo

typeset -g VI_MODE_INDICATOR='❯'

_vi_cursor() {
  [[ ${TERM-} != dumb ]] || return 0

  case $1 in
    block)
      printf '\e[2 q'
      ;;
    under)
      printf '\e[4 q'
      ;;
    beam)
      printf '\e[6 q'
      ;;
  esac
}

_vi_update_mode() {
  case $KEYMAP in
    vicmd)
      VI_MODE_INDICATOR='❮'
      _vi_cursor block
      ;;
    *)
      if [[ $ZLE_STATE == *overwrite* ]]; then
        VI_MODE_INDICATOR='❱'
        _vi_cursor under
      else
        VI_MODE_INDICATOR='❯'
        _vi_cursor beam
      fi
      ;;
  esac
}

_vi_keymap_select() {
  _vi_update_mode
  zle reset-prompt
}
zle -N _vi_keymap_select

_vi_line_init() {
  ((${+terminfo[smkx]})) && echoti smkx

  zle -K viins
  _vi_update_mode
}
zle -N _vi_line_init

_vi_line_finish() {
  ((${+terminfo[rmkx]})) && echoti rmkx
  _vi_cursor block
}
zle -N _vi_line_finish

autoload -Uz add-zle-hook-widget

add-zle-hook-widget keymap-select _vi_keymap_select
add-zle-hook-widget line-init _vi_line_init
add-zle-hook-widget line-finish _vi_line_finish

expand-alias-space() {
  local alias_name remove_space=1

  for alias_name in "${baliases[@]}"; do
    if [[ $LBUFFER == "$alias_name" || $LBUFFER == *" $alias_name" ]]; then
      remove_space=0
      break
    fi
  done

  for alias_name in "${ealiases[@]}"; do
    if (($+widgets[_expand_alias])) && [[ $LBUFFER == *"$alias_name" ]]; then
      zle _expand_alias
      break
    fi
  done

  zle self-insert

  ((!remove_space)) && zle backward-delete-char
}

zle -N expand-alias-space
bindkey -M viins ' ' expand-alias-space
bindkey -M viins '^ ' magic-space

vi-yank-clip() {
  zle vi-yank

  (($+commands[pbcopy])) && print -rn -- "$CUTBUFFER" | command pbcopy &> /dev/null
}

zle -N vi-yank-clip
bindkey -M vicmd 'y' vi-yank-clip
bindkey -M visual 'y' vi-yank-clip

typeset -gA _keys

_keys=(
  BackTab "${terminfo[kcbt]}"
  CtrlLeft "${terminfo[kLFT5]}"
  CtrlRight "${terminfo[kRIT5]}"
  Delete "${terminfo[kdch1]}"
  Down "${terminfo[kcud1]}"
  End "${terminfo[kend]}"
  Home "${terminfo[khome]}"
  Left "${terminfo[kcub1]}"
  Right "${terminfo[kcuf1]}"
  Up "${terminfo[kcuu1]}"
)

autoload -Uz \
  up-line-or-beginning-search \
  down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank

bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

bindkey -M viins '^[[Z' reverse-menu-complete

bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^S' history-incremental-pattern-search-forward

_bindkey_terminfo() {
  local km=$1 key=$2 widget=$3
  [[ -n ${_keys[$key]} ]] && bindkey -M "$km" -- "${_keys[$key]}" "$widget"
}

for km in viins vicmd; do
  _bindkey_terminfo "$km" Home beginning-of-line
  _bindkey_terminfo "$km" End end-of-line
  _bindkey_terminfo "$km" Delete delete-char

  _bindkey_terminfo "$km" Up up-line-or-beginning-search
  _bindkey_terminfo "$km" Down down-line-or-beginning-search

  _bindkey_terminfo "$km" CtrlLeft backward-word
  _bindkey_terminfo "$km" CtrlRight forward-word
done

unset km
unset _keys
unfunction _bindkey_terminfo

bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

bindkey -M vicmd '/' history-incremental-pattern-search-backward
bindkey -M vicmd '?' history-incremental-pattern-search-forward

bindkey -M vicmd '%' vi-match-bracket

bindkey -M vicmd 'g~' vi-oper-swap-case

bindkey -M vicmd 'u' undo
bindkey -M vicmd '^R' redo

bindkey -M vicmd -r '~'

autoload -Uz edit-command-line
zle -N edit-command-line

bindkey -M viins '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line

autoload -Uz select-bracketed select-quoted

zle -N select-bracketed
zle -N select-quoted

for km in viopp visual; do
  for c in \
    'a(' 'i(' 'a)' 'i)' \
    'a[' 'i[' 'a]' 'i]' \
    'a{' 'i{' 'a}' 'i}' \
    'a<' 'i<' 'a>' 'i>' \
    'ab' 'ib' 'aB' 'iB'; do
    bindkey -M "$km" "$c" select-bracketed
  done

  for c in \
    "a'" "i'" \
    'a"' 'i"' \
    'a`' 'i`'; do
    bindkey -M "$km" "$c" select-quoted
  done
done

unset km c

autoload -Uz surround

zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

bindkey -M vicmd -r 's'
bindkey -M vicmd 'sd' delete-surround
bindkey -M vicmd 'sr' change-surround
bindkey -M vicmd 'sa' add-surround

bindkey -M visual 'S' add-surround

magic-enter() {
  unfunction magic-enter

  _magic-enter() {
    [[ -n $BUFFER || $CONTEXT != start ]] && return

    if (($+commands[git])) && command git rev-parse --is-inside-work-tree &> /dev/null; then
      BUFFER=' git status -sbu .'
    else
      BUFFER=' ls .'
    fi
  }

  case ${widgets[accept-line]} in
    user:*)
      zle -N _magic-enter_orig_accept-line "${widgets[accept-line]#user:}"
      _magic-enter_accept-line() {
        _magic-enter
        zle _magic-enter_orig_accept-line -- "$@"
      }
      ;;
    *)
      _magic-enter_accept-line() {
        _magic-enter
        zle .accept-line
      }
      ;;
  esac

  zle -N accept-line _magic-enter_accept-line
}

zsh-defer magic-enter || magic-enter

pound-toggle() {
  if [[ $BUFFER == '#'* ]]; then
    if ((CURSOR > 0)); then
      ((CURSOR -= 1))
    fi
    BUFFER="${BUFFER:1}"
  else
    BUFFER="#$BUFFER"
    ((CURSOR += 1))
  fi
}
zle -N pound-toggle
bindkey -M vicmd '#' pound-toggle

sudo-toggle() {
  if [[ $BUFFER == sudo\ * ]]; then
    BUFFER="${BUFFER#sudo }"
  else
    BUFFER="sudo $BUFFER"
  fi
  CURSOR=${#BUFFER}
}
zle -N sudo-toggle
bindkey -M vicmd '!' sudo-toggle
bindkey -M viins '^x^s' sudo-toggle

symmetric-ctrl-z() {
  if [[ ${#BUFFER} -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N symmetric-ctrl-z
bindkey '^z' symmetric-ctrl-z

dot-expansion() {
  if [[ $LBUFFER == *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N dot-expansion
bindkey -M viins '.' dot-expansion
