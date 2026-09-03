#!/usr/bin/env bash

# -e: exit on error
# -u: error on undefined variable
# -o pipefail: fail if any command in a pipeline fails
set -euo pipefail

# Avoid word-splitting issues
IFS=$'\n\t'

SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
BIN_DIR="${HOME}/.local/bin"
DOTFILES_REPO="${DOTFILES_REPO:-devastion/dotfiles}"
DRY_RUN=false
NO_APPLY=false
OS="$(uname -s)"
CURL_OPTIONS=(
  '--fail'
  '--silent'
  '--show-error'
  '--location'
  '--proto'
  '=https'
  '--tlsv1.2'
)

_color() {
  local color_code="$1"
  shift

  if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
    printf '\033[%sm%s\033[0m\n' "$color_code" "$*" >&2
  else
    printf '%s\n' "$*" >&2
  fi
}

_error() {
  _color "0;31" "$@"
}

_info() {
  _color "0;34" "$@"
}

_ok() {
  _color "1;32" "$@"
}

_warn() {
  _color "1;33" "$@"
}

_on_error() {
  local status=$?
  _error "Installation failed on line ${BASH_LINENO[1]:-unknown}"
  exit "$status"
}

trap '_on_error' ERR

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  if ! command_exists "$1"; then
    _error "Required command not found: $1"
    return 1
  fi
}

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Options:
  -n, --dry-run   Show what would be installed without making changes
      --no-apply  Install prerequisites only; skip `chezmoi init --apply`
  -h, --help      Show this help message

Environment:
  DOTFILES_REPO   Source repository (default: devastion/dotfiles)
EOF
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      -n | --dry-run)
        DRY_RUN=true
        ;;
      --no-apply)
        NO_APPLY=true
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        _error "Unknown option: $1"
        usage >&2
        return 2
        ;;
      *)
        _error "Unexpected argument: $1"
        usage >&2
        return 2
        ;;
    esac
    shift
  done

  if (($# > 0)); then
    _error "Unexpected argument: $1"
    usage >&2
    return 2
  fi
}

_install_chezmoi() {
  local chezmoi="${BIN_DIR}/chezmoi"

  if "$DRY_RUN"; then
    _info "Would install chezmoi to ${chezmoi}"
    return 0
  fi

  require_command curl
  _info "Installing chezmoi to ${chezmoi}"
  mkdir -p -- "$BIN_DIR"

  curl "${CURL_OPTIONS[@]}" https://chezmoi.io/get \
    | sh -s -- -b "$BIN_DIR"

  [[ -x "$chezmoi" ]] || {
    _error "chezmoi installation completed without creating ${chezmoi}"
    return 1
  }
}

_install_mise() {
  local mise="${BIN_DIR}/mise"

  if "$DRY_RUN"; then
    _info "Would install mise to ${mise}"
    return 0
  fi

  require_command curl
  _info "Installing mise to ${mise}"
  mkdir -p -- "$BIN_DIR"

  curl "${CURL_OPTIONS[@]}" https://mise.run \
    | MISE_INSTALL_PATH="$mise" sh

  [[ -x "$mise" ]] || {
    _error "mise installation completed without creating ${mise}"
    return 1
  }
}

_install_homebrew() {
  if "$DRY_RUN"; then
    _info 'Would install Homebrew'
    return 0
  fi

  require_command curl
  _info 'Installing Homebrew (may prompt for your password)'

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl "${CURL_OPTIONS[@]}" \
      https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    </dev/null

  local brew
  for brew in '/opt/homebrew/bin/brew' '/usr/local/bin/brew'; do
    if [[ -x "$brew" ]]; then
      eval "$("$brew" shellenv)"
      return 0
    fi
  done

  _error 'Homebrew installation failed'
  return 1
}

_apply_dotfiles() {
  if "$DRY_RUN"; then
    _info "Would run: chezmoi init --apply ${DOTFILES_REPO}"
    return 0
  fi

  _info "Applying dotfiles from ${DOTFILES_REPO}"
  chezmoi init --apply -- "$DOTFILES_REPO" </dev/null
}

main() {
  parse_args "$@"

  if "$DRY_RUN"; then
    _info "Dry run enabled! No changes will be made."
  fi

  _info "Executing install.sh from ${SCRIPT_DIR}"

  if ! "$DRY_RUN"; then
    mkdir -p -- "$BIN_DIR"
  fi

  if ! "$DRY_RUN"; then
    case ":${PATH-}:" in
      *:"${BIN_DIR}":*) ;;
      *)
        PATH="${BIN_DIR}${PATH:+:${PATH}}"
        export PATH
        ;;
    esac
  fi

  if ! command_exists 'chezmoi'; then
    _install_chezmoi
    if ! "$DRY_RUN"; then
      _ok "chezmoi installed"
    fi
  else
    _ok 'chezmoi is on $PATH'
  fi

  if ! command_exists 'mise'; then
    _install_mise
    if ! "$DRY_RUN"; then
      _ok "mise installed"
    fi
  else
    _ok 'mise is on $PATH'
  fi

  if [[ "$OS" == 'Darwin' ]]; then
    if ! command_exists 'brew'; then
      _install_homebrew
      if ! "$DRY_RUN"; then
        _ok 'Homebrew installed'
      fi
    else
      _ok 'Homebrew is on $PATH'
    fi
  fi

  if "$NO_APPLY"; then
    _info "Skipping apply. Run: chezmoi init --apply ${DOTFILES_REPO}"
    return 0
  fi

  _apply_dotfiles

  if ! "$DRY_RUN"; then
    _ok 'Dotfiles applied. Restart your terminal.'
  fi
}

main "$@"
