#!/usr/bin/env bash

set -euo pipefail

command -v bat >/dev/null 2>&1 || exit 0

echo 'Rebuilding bat theme cache...'
bat cache --build
