#!/usr/bin/env sh

# -e: exit on error
# -u: exit on unset variables
set -eu

if ! gpg --list-secret-keys | grep -q "{{ .email }}"; then
  export GPG_TTY=$(tty)
  gpg --batch --import ~/.gnupg/public.asc
  gpg --batch --pinentry-mode loopback --import ~/.gnupg/private.asc
fi
