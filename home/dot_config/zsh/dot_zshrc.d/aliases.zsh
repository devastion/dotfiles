#!/usr/bin/env zsh

# copy/paste
alias -g pbc="pbcopy"
alias -g pbp="pbpaste"

# ls
alias l="eza --git"
alias ll="l -lao --group-directories-first"
alias ld="l -lD"
alias lf="l -lf"
alias lh="l -ld .* --group-directories-first"
alias lt="l -la --sort=modified --reverse"
alias ls="ll"
alias lsg="l -ao --group-directories-first --grid"

alias "cd.."="cd_up"
alias nr="npm run"
alias dco="docker compose"

function dcs() {
  local containers=($(docker ps -q))
  if [ ${#containers[@]} -eq 0 ]; then
    echo "No docker containers running!"
    return 1
  fi

  echo "Stopping all docker containers..."
  docker stop ${containers[@]}
  return 0
}

function mnvim() {
  mise x node@lts -- nvim "$@"
}

alias nvim="mnvim"
alias ch="chezmoi"

# pipe
alias -g H="| head"
alias -g T="| tail"
alias -g G="| rg"
alias -g L="| less"
alias -g M="| most"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g P="2>&1| pygmentize -l pytb"
