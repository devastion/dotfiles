#!/usr/bin/env zsh

# aliases

# macos
if is-macos; then
  function unquarantine() {
    for attribute in com.apple.metadata:kMDItemDownloadedDate com.apple.metadata:kMDItemWhereFroms com.apple.quarantine; do
      xattr -r -d "$attribute" "$@"
    done
  }
fi
alias pbc="pbcopy"
alias pbp="pbpaste"

# history
alias h="history"
alias hl="history | less"
alias hs="history | grep"
alias hsi="history | grep -i"

# ls
alias l="eza --git"
alias ll="l -lao --group-directories-first"
alias ld="l -lD"
alias lf="l -lf"
alias lh="l -ld .* --group-directories-first"
alias lt="l -la --sort=modified --reverse"
alias ls="ll"
alias lsg="l -ao --group-directories-first --grid"

# shell
alias q="exit"
alias rm="rm -i"
alias hgrep="fc -El 0 | grep"
alias help="man"
alias p="ps -f"
alias sortnr="sort -n -r"
alias unexport="unset"
alias ndate="date \"+%d-%m-%y\""
alias rl="reset && exec zsh -l"

# search
alias grep="grep --color"
alias sgrep="grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} "

# navigation
alias "cd.."="cd_up"

# misc
if ! command -v pwgen &>/dev/null; then
  alias mypw="pwgen -c -n -s -y 26 -1"
fi
alias nr="npm run"

# command line head / tail shortcuts
alias -g H="| head"
alias -g T="| tail"
alias -g G="| grep"
alias -g L="| less"
alias -g M="| most"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g P="2>&1| pygmentize -l pytb"

alias t="tail -f"

# docker
function dcs() {
  docker stop $(docker ps -q)
}
alias dco="docker compose"

# editor
alias nv="mise x node@latest -- nvim"
