#!/usr/bin/env zsh

function _command_exists {
  if builtin command -v $1 >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

# =============================================================================
# ZSH EVALCACHE
# =============================================================================
# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache [NAME=VALUE]... COMMAND [ARG]...
# eval "$(zoxide init zsh)" -> _evalcache zoxide init zsh
# use export ZSH_EVALCACHE_DISABLE=true to disable

# default cache directory
local ZSH_EVALCACHE_DIR="${ZCACHEDIR:-$XDG_CACHE_HOME/zsh}/.zsh-evalcache"

function _evalcache() {
  local cmd_hash="nohash" data="$*" name

  # use the first non-variable argument as the name
  for name in $@; do
    if [ "${name}" = "${name#[A-Za-z_][A-Za-z0-9_]*=}" ]; then
      break
    fi
  done

  if ! _command_exists $name; then
    echo "${funcsourcetrace[1]}: Command $name doesn't exists."
    return 1
  fi

  # if command is a function, include its definition in data
  if typeset -f "${name}" >/dev/null; then
    data=${data}$(typeset -f "${name}")
  fi

  if _command_exists md5; then
    cmd_hash=$(echo -n "${data}" | md5)
  elif _command_exists md5sum; then
    cmd_hash=$(echo -n "${data}" | md5sum | cut -d' ' -f1)
  fi

  local cache_file="$ZSH_EVALCACHE_DIR/init-${name##*/}-${cmd_hash}.sh"

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval ${(q)@}
  elif [ -s "$cache_file" ]; then
    source "$cache_file"
  else
    if type "${name}" >/dev/null; then
      echo "evalcache: ${name} initialization not cached, caching output of: $*" >&2
      mkdir -p "$ZSH_EVALCACHE_DIR"
      eval ${(q)@} >"$cache_file"
      zcompile "$cache_file"
      source "$cache_file"
    else
      echo "evalcache: ERROR: ${name} is not installed or in PATH" >&2
    fi
  fi
}

function _evalcache_clear() {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.{sh,zwc}
}
