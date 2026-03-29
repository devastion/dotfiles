#!/usr/bin/env sh

cd_up() {
  _git_root="$(git rev-parse --show-toplevel 2>/dev/null)"

  if [ -n "$_git_root" ] && [ "$(pwd)" = "$_git_root" ] && [ -z "$1" ]; then
    builtin cd .. || return
    unset _git_root
    return 0
  fi

  if [ -n "$_git_root" ] && [ -z "$1" ]; then
    builtin cd "$_git_root" || return
    unset _git_root
    return 0
  fi

  unset _git_root

  if [ -z "$1" ]; then
    cd ..
    return 0
  fi

  cd "$(printf "%0.s../" $(seq 1 "$1"))" || return
  return 0
}

copyfile() {
  if [ -z "$1" ]; then
    echo "Usage: copyfile <file>"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: '$1' is not a valid file."
    return 1
  fi

  pbcopy <"$1" || return 1
  echo "$1 copied to clipboard."
}

copypath() {
  _file=${1:-.}

  case $_file in
  /*) _path=$_file ;;
  *) _path=$PWD/$_file ;;
  esac

  if [ -d "$_path" ]; then
    _abs_path=$(cd "$_path" 2>/dev/null && pwd) || return 1
  else
    _dir=$(dirname "$_path")
    _base=$(basename "$_path")
    _abs_path=$(cd "$_dir" 2>/dev/null && pwd)/$_base || return 1
  fi

  printf '%s' "$_abs_path" | pbcopy || return 1
  echo "$_abs_path copied to clipboard."

  unset _file _path _abs_path _dir _base
}

cp() {
  if [ -z "$2" ]; then
    command cp -rv "$1" ./
  else
    command cp -rv "$@"
  fi
}

dai() {
  if ! docker ps -q | grep -q .; then
    echo "No docker containers running!"
    return 1
  fi

  if [ -n "$1" ]; then
    _cid="$(docker ps -q --filter "name=$1" | head -n1)"
  else
    _cid="$(
      docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" |
        fzf -1 |
        awk '{print $1}'
    )" || return 1
  fi

  if [ -z "$_cid" ]; then
    echo "Couldn't find container id"
    return 1
  fi

  docker exec -it "$_cid" sh -c "if [ -x /bin/zsh ]; then exec /bin/zsh; elif [ -x /bin/bash ]; then exec /bin/bash; else exec /bin/sh; fi"

  unset _cid
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xvjf "$1" ;;
    *.tar.gz) tar xvzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xvf "$1" ;;
    *.tbz2) tar xvjf "$1" ;;
    *.tgz) tar xvzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

flushdns() {
  dscacheutil -flushcache && sudo killall -HUP mDNSResponder
}

gco() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not in git repository!"
    return 1
  fi

  _branches="$(
    git for-each-ref \
      --count=30 \
      --sort=-committerdate \
      refs/heads/ \
      --format='%(refname:short)'
  )"

  if [ -z "$_branches" ]; then
    echo "No branches found"
    return 1
  fi

  _branch="$(
    printf '%s\n' "$_branches" | fzf
  )" || return 1

  git checkout "$_branch"

  unset _branches _branch
}

mkcd() {
  _dir="$*"
  mkdir -p "$_dir" && cd "$_dir" || return
}

mv() {
  if [ -z "$2" ]; then
    command mv -v "$1" ./
  else
    command mv -v "$@"
  fi
}

which() {
  builtin which -a "$@" | bat --language=sh --wrap=character
}

unquarantine() {
  if [ $# -eq 0 ]; then
    echo "Usage: unquarantine <file|app> [...]"
    return 1
  fi

  for attribute in com.apple.metadata:kMDItemDownloadedDate com.apple.metadata:kMDItemWhereFroms com.apple.quarantine; do
    xattr -r -d "${attribute}" "$@"
  done
}
