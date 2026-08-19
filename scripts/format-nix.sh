#!/usr/bin/env bash
# Format Nix files with deadnix, statix, and nixfmt.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ $# -gt 0 ]]; then
  files=("$@")
else
  mapfile -t files < <(find . -name '*.nix' -not -path './result*' -not -path './.git/*')
fi

deadnix -e "${files[@]}"
statix fix "${files[@]}"
nixfmt "${files[@]}"
