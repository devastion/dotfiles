#!/usr/bin/env bash

# -e: exit on error
# -u: error on undefined variable
# -o pipefail: fail if any command in a pipeline fails
set -euo pipefail

# avoid word splitting issues
IFS=$'\n\t'

trap 'echo "Error on line $LINENO"; exit 1' ERR
