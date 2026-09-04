#!/usr/bin/env zsh

setopt prompt_subst

zmodload zsh/datetime
autoload -Uz add-zsh-hook

typeset -gF _PROMPT_MIN_DURATION=2.0

typeset -g _PROMPT_GIT_STATUS=''
typeset -g _PROMPT_CMD_STATUS=''
typeset -g _PROMPT_CMD_INFO=''

typeset -gF _PROMPT_START_TIME=-1

typeset -g _PROMPT_SSH_INDICATOR=''
typeset -g _PROMPT_NESTED_SHELL_INDICATOR=''

if [[ -n $SSH_CONNECTION || -n $SSH_TTY || -n $SSH_CLIENT ]]; then
  _PROMPT_SSH_INDICATOR=' %F{yellow}%n@%m%f'
fi

typeset -x _PROMPT_SHELL_PID="${_PROMPT_SHELL_PID:-$$}"
typeset -x _PROMPT_TMUX_PANE="${_PROMPT_TMUX_PANE:-}"

if [[ -n $TMUX && $TMUX_PANE != "$_PROMPT_TMUX_PANE" ]]; then
  _PROMPT_SHELL_PID="$$"
  _PROMPT_TMUX_PANE="$TMUX_PANE"
fi

if (("$_PROMPT_SHELL_PID" != $$)); then
  _PROMPT_NESTED_SHELL_INDICATOR="%F{yellow}%f "
fi

_prompt_duration() {
  local -F secs="$1"
  local -i total="${secs%.*}"
  local -i h="$((total / 3600))"
  local -i m="$((total % 3600 / 60))"
  local -i s="$((total % 60))"

  if ((h)); then
    REPLY="${h}h${m}m${s}s"
  elif ((m)); then
    REPLY="${m}m${s}s"
  else
    local -i tenths=$(((secs * 10) % 10))
    REPLY="${s}.${tenths}s"
  fi
}

_prompt_git() {
  local line oid branch repo toplevel REPLY
  local -i in_repo=0
  local -i staged=0 unstaged=0 untracked=0 conflicted=0 ahead=0 behind=0
  local -a segments

  (($+commands[git])) || return 1

  while IFS= read -r line; do
    case $line in
      '1 '* | '2 '*)
        [[ $line[3] != . ]] && ((staged++))
        [[ $line[4] != . ]] && ((unstaged++))
        ;;
      '? '*)
        ((untracked++))
        ;;
      'u '*)
        ((conflicted++))
        ;;
      '# branch.oid '*)
        oid=${line#'# branch.oid '}
        in_repo=1
        ;;
      '# branch.head '*)
        branch=${line#'# branch.head '}
        ;;
      '# branch.ab '*)
        local ab=${line#'# branch.ab '}
        local -a fields=(${(s: :)ab})
        ahead=${fields[1]#+}
        behind=${fields[2]#-}
        ;;
    esac
  done < <(git --no-optional-locks status --porcelain=v2 --branch 2> /dev/null)

  ((in_repo)) || return 1

  if [[ $branch == '(detached)' ]]; then
    branch="HEAD (${oid[1,7]})"
  fi

  toplevel=$(git --no-optional-locks rev-parse --show-toplevel 2> /dev/null)
  repo="${toplevel:t}"

  _PROMPT_GIT_STATUS=" %F{green}󰘬 ${repo}%f %F{yellow}on%f %F{red}${branch}%f"

  ((staged)) && segments+=("%F{green}+${staged}%f")
  ((unstaged)) && segments+=("%F{yellow}!${unstaged}%f")
  ((untracked)) && segments+=("%F{cyan}?${untracked}%f")
  ((conflicted)) && segments+=("%F{red}=${conflicted}%f")
  ((ahead)) && segments+=("%F{magenta}⇡${ahead}%f")
  ((behind)) && segments+=("%F{blue}⇣${behind}%f")

  if ((${#segments})); then
    _PROMPT_GIT_STATUS+=" %B[${(j: :)segments}]%b"
  fi

  return 0
}

_prompt_preexec() {
  _PROMPT_START_TIME=$EPOCHREALTIME
}

_prompt_precmd() {
  local -i exit_code=$?
  local -F elapsed
  local -a info
  local REPLY

  if ((exit_code == 0)); then
    _PROMPT_CMD_STATUS='%F{green}'
  else
    _PROMPT_CMD_STATUS='%F{red}'
    info+=("%F{red}${exit_code}%f")
  fi

  if ((_PROMPT_START_TIME >= 0)); then
    elapsed=$((EPOCHREALTIME - _PROMPT_START_TIME))
    _PROMPT_START_TIME=-1

    if ((elapsed >= _PROMPT_MIN_DURATION)); then
      _prompt_duration $elapsed
      info+=("%F{yellow}${REPLY}%f")
    fi
  fi

  _PROMPT_CMD_INFO=" ${(j: :)info}"

  _PROMPT_GIT_STATUS=''
  _prompt_git
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

PROMPT=$'\n%B%F{blue}%~%f%b${_PROMPT_GIT_STATUS}${_PROMPT_SSH_INDICATOR}${_PROMPT_CMD_INFO}\n${_PROMPT_NESTED_SHELL_INDICATOR}${_PROMPT_CMD_STATUS}${VI_MODE_INDICATOR}%f '
