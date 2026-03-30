#!/usr/bin/env sh

# -e: exit on error
# -u: exit on unset variables
set -eu

_mise_path="$HOME/.local/bin/mise"

if ! builtin command -v "$_mise_path" >/dev/null 2>&1; then
  curl https://mise.run | MISE_INSTALL_PATH="$_mise_path" sh
  curl https://mise.run | MISE_INSTALL_PATH=~/.local/bin/mise-x64 MISE_INSTALL_ARCH=x64 sh
fi

MISE_VERBOSE=1 exec "$_mise_path" install
