#!/usr/bin/env zsh

setopt prompt_subst
setopt transient_rprompt

zmodload zsh/datetime
autoload -Uz add-zsh-hook

typeset -gF PROMPT_MIN_DURATION=2.0

typeset -g PATH_INFO=''
typeset -g GIT_INFO=''
typeset -g CMD_STATUS=''

typeset -gF _PROMPT_START_TIME=-1

_prompt_escape() {
  REPLY=${1//\%/%%}
}

_prompt_duration() {
  local -F secs=$1
  local -i total=$secs
  local -i h=$((total / 3600)) m=$((total % 3600 / 60)) s=$((total % 60))
  local -i tenths=$(((secs - total) * 10))

  if ((h)); then
    REPLY="${h}h${m}m${s}s"
  elif ((m)); then
    REPLY="${m}m${s}s"
  else
    REPLY="${s}.${tenths}s"
  fi
}

_git_prompt() {
  local line oid branch repo REPLY
  local -i in_repo=0
  local -i staged=0 unstaged=0 untracked=0 conflicted=0 ahead=0 behind=0
  local -a segments fields

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
        fields=(${(s: :)${line#'# branch.ab '}})
        ahead=${fields[1]#+}
        behind=${fields[2]#-}
        ;;
    esac
  done < <(git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)

  ((in_repo)) || return 1

  if [[ $branch == '(detached)' ]]; then
    branch=${oid[1,7]:+HEAD (${oid[1,7]})}
  fi

  repo=${$(git rev-parse --show-toplevel 2>/dev/null):t}
  _prompt_escape ${repo:-'(unknown)'}
  GIT_INFO="%F{green}󰘬 ${REPLY}%f"

  _prompt_escape ${branch:-'(unknown)'}
  GIT_INFO+=" %F{red}${REPLY}%f"

  ((staged)) && segments+=("%F{green}+${staged}%f")
  ((unstaged)) && segments+=("%F{yellow}!${unstaged}%f")
  ((untracked)) && segments+=("%F{cyan}?${untracked}%f")
  ((conflicted)) && segments+=("%F{red}=${conflicted}%f")
  ((ahead)) && segments+=("%F{magenta}⇡${ahead}%f")
  ((behind)) && segments+=("%F{blue}⇣${behind}%f")

  (($#segments)) \
    && GIT_INFO+=" %B[${(j: :)segments}]%b"

  return 0
}

_refresh_prompt() {
  local REPLY

  GIT_INFO=''

  if _git_prompt; then
    PATH_INFO='%~'
  else
    PATH_INFO='%~'
  fi
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
    CMD_STATUS='%F{green}'
  else
    CMD_STATUS='%F{red}'
    info+=("%F{red}${exit_code}%f")
  fi

  if ((_PROMPT_START_TIME >= 0)); then
    elapsed=$((EPOCHREALTIME - _PROMPT_START_TIME))
    _PROMPT_START_TIME=-1

    if ((elapsed >= PROMPT_MIN_DURATION)); then
      _prompt_duration $elapsed
      info+=("%F{yellow}${REPLY}%f")
    fi
  fi

  _refresh_prompt
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

PROMPT=$'\n%B%F{blue}${PATH_INFO}%f%b ${GIT_INFO}\n${CMD_STATUS}${VI_MODE_INDICATOR}%f '
