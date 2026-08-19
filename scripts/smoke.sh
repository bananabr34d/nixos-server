#!/usr/bin/env bash
# Light HTTP checks. Run on any tailnet host:  just smoke [primary|standby]
set -euo pipefail

host="${1:-$(hostname -s)}"
me_primary="$(nix eval --raw --impure --expr '(import ./lib/me.nix).primaryHost' 2>/dev/null || echo primary)"

ok() { echo "  ok  $1"; }
bad() { echo "  FAIL $1" >&2; fail=1; }

fail=0
echo "smoke ${host}"

if [[ "$host" == "$me_primary" || "$host" == "primary" ]]; then
  for url in \
    "http://${host}:2283" \
    "http://${host}:3000" \
    "http://${host}:5000/nix-cache-info"
  do
    if curl -fsS --connect-timeout 3 -o /dev/null "$url"; then
      ok "$url"
    else
      bad "$url"
    fi
  done
else
  echo "  (standby: apps are off by design)"
  if command -v zpool >/dev/null; then
    zpool status -x || true
  fi
fi

exit "${fail:-0}"
