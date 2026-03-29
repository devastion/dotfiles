#!/usr/bin/env sh

# copy/paste (global aliases when sourced from zsh)
if [ -n "$ZSH_VERSION" ]; then
  alias -g pbc="pbcopy"
  alias -g pbp="pbpaste"
else
  alias pbc="pbcopy"
  alias pbp="pbpaste"
fi

# ls
alias l="eza --git"
alias ll="l -lao --group-directories-first"
alias ld="l -lD"
alias lf="l -lf"
alias lh="l -ld .* --group-directories-first"
alias lt="l -la --sort=modified --reverse"
alias ls="ll"
alias lsg="l -ao --group-directories-first --grid"

history_stat() {
  history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head
}

alias "cd.."="cd_up"
alias nr="npm run"
alias dco="docker compose"
alias dcoup="dco up --pull never"

dcs() {
  containers=$(docker ps -q)
  if [ -z "$containers" ]; then
    echo "No docker containers running!"
    return 1
  fi

  echo "Stopping all docker containers..."
  echo "$containers" | xargs docker stop
  echo "All docker containers are stopped!"
  return 0
}

mnvim() {
  mise x node@lts -- nvim "$@"
}

alias nvim="mnvim"
alias pnvim="PROF=1 nvim"
alias ch="chezmoi"

# tmux
alias ta="tmux a -t "
alias tl="tmux ls"
alias tksv="tmux kill-server"

# pipe (global aliases when sourced from zsh)
if [ -n "$ZSH_VERSION" ]; then
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
else
  alias H="| head"
  alias T="| tail"
  alias G="| rg"
  alias L="| less"
  alias M="| most"
  alias LL="2>&1 | less"
  alias CA="2>&1 | cat -A"
  alias NE="2> /dev/null"
  alias NUL="> /dev/null 2>&1"
  alias P="2>&1| pygmentize -l pytb"
fi
