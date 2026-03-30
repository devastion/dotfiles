#!/usr/bin/env sh

if ! gpg --list-secret-keys | grep -q "{{ .email }}"; then
  export GPG_TTY=$(tty)
  gpg --batch --import ~/.gnupg/public.asc
  gpg --batch --pinentry-mode loopback --import ~/.gnupg/private.asc
fi
