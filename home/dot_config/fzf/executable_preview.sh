#!/usr/bin/env bash

if [ -d "$1" ]; then
  eza --tree --level=3 --color=always "$1" | head -200
elif file --mime --brief "$1" | grep -q 'charset=binary'; then
  hexyl --border none --length 2KiB "$1" 2> /dev/null || echo "Binary file"
else
  bat --color=always --line-range :500 "$1"
fi
