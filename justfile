# Server flake — day to day
#
#   edit → commit → pull on the machine → just switch
#   from a fast Linux box: just push-cache primary standby
#
# just switch never activates another computer.

host := `hostname -s`
flake := justfile_directory()
nixos_hosts := "primary standby"

default:
    @just --list --unsorted

hosts:
    @echo "This machine: {{ host }}"
    @echo "NixOS hosts: {{ nixos_hosts }}"
    @echo
    @echo "  just pull-switch"
    @echo "  just push-cache primary standby"

pull:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ flake }}"
    git pull --ff-only

pull-switch: pull switch
    @just smoke

switch *args:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ flake }}"
    target="$(hostname -s)"
    if [[ -n "{{ args }}" ]]; then
      target="$(echo "{{ args }}" | awk '{print $1}')"
    fi
    self="$(hostname -s)"
    if [[ "${target}" != "${self}" && "${FORCE:-}" != "1" ]]; then
      echo "error: just switch is local only (self=${self}, requested=${target})." >&2
      exit 1
    fi
    echo "NixOS  Switching: ${target}"
    nh os switch . --hostname "${target}"
    nixos-needsreboot 2>/dev/null || true

build *args:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ flake }}"
    target="${1:-$(hostname -s)}"
    if [[ -n "{{ args }}" ]]; then
      target="$(echo "{{ args }}" | awk '{print $1}')"
    fi
    nh os build . --hostname "${target}"

# Build a host and copy the closure to the primary over SSH (Harmonia).
push-cache *args:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ flake }}"
    me="$(nix eval --raw --impure --expr '(import ./lib/me.nix).username')"
    primary="$(nix eval --raw --impure --expr '(import ./lib/me.nix).primaryHost')"
    hosts=()
    if [[ -n "{{ args }}" ]]; then
      # shellcheck disable=SC2206
      hosts=( {{ args }} )
    else
      hosts=( "$(hostname -s)" )
    fi
    if ! curl -fsS --connect-timeout 3 "http://${primary}:5000/nix-cache-info" >/dev/null 2>&1; then
      echo "error: cannot reach http://${primary}:5000 (is Harmonia on?)" >&2
      exit 1
    fi
    for h in "${hosts[@]}"; do
      echo "Build ${h} + copy → ${me}@${primary}"
      toplevel=$(nix build --no-link --print-out-paths ".#nixosConfigurations.${h}.config.system.build.toplevel")
      nix copy --to "ssh-ng://${me}@${primary}" --no-check-sigs "${toplevel}"
    done
    echo "On each target:  just pull-switch"

smoke *args:
    #!/usr/bin/env bash
    set -euo pipefail
    h="$(hostname -s)"
    if [[ -n "{{ args }}" ]]; then
      h="$(echo "{{ args }}" | awk '{print $1}')"
    fi
    bash "{{ flake }}/scripts/smoke.sh" "${h}"

check:
    @cd "{{ flake }}" && nix flake check --no-build

update:
    cd "{{ flake }}" && nix flake update
    @echo "Review flake.lock, commit, then switch each host."

gc:
    nh clean all --keep 5

rollback:
    sudo nixos-rebuild --rollback switch --flake "{{ flake }}#$(hostname -s)"

format *paths:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ flake }}"
    nix shell --inputs-from . \
      nixpkgs#deadnix nixpkgs#statix nixpkgs#nixfmt \
      -c bash "{{ flake }}/scripts/format-nix.sh" {{ paths }}
