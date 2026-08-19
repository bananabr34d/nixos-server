#!/usr/bin/env bash
# Wipe the target disks with disko and nixos-install this flake.
#
#   sudo ./scripts/install-system.sh primary
#   sudo ./scripts/install-system.sh standby
#
# Inspired by wimpysworld/nix-config's install-system.sh.
set -euo pipefail

if command -v tput >/dev/null; then
  RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4); BOLD=$(tput bold); NC=$(tput sgr0)
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi
info()    { echo "${BLUE}${BOLD}[INFO]${NC} $1"; }
warn()    { echo "${YELLOW}${BOLD}[WARN]${NC} $1"; }
error()   { echo "${RED}${BOLD}[ERROR]${NC} $1" >&2; exit 1; }
success() { echo "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }

TARGET_HOST="${1:-}"
[[ -n "$TARGET_HOST" ]] || error "usage: $0 primary|standby"
INSTALL_USER="${INSTALL_USER:-alice}"

find_flake_dir() {
  if [[ -n "${FLAKE_DIR:-}" && -f "${FLAKE_DIR}/flake.nix" ]]; then
    echo "$FLAKE_DIR"
    return
  fi
  local dir="$PWD"
  while [[ "$dir" != / ]]; do
    [[ -f "$dir/flake.nix" ]] && { echo "$dir"; return; }
    dir="$(dirname "$dir")"
  done
  error "Could not find flake.nix"
}

FLAKE_DIR="$(find_flake_dir)"
cd "$FLAKE_DIR"
[[ "$(id -u)" -eq 0 ]] || error "Run as root"

if nix eval --raw ".#nixosConfigurations.${TARGET_HOST}.config.disko.devices.disk.nvme.device" 2>/dev/null | grep -q REPLACE-ME; then
  error "Replace REPLACE-ME disk ids in modules/hosts/${TARGET_HOST}/disko.nix first."
fi

echo
warn "This will WIPE the disks listed for host '${TARGET_HOST}' (OS + data)."
read -r -p "Type the hostname to continue: " confirm
[[ "$confirm" == "$TARGET_HOST" ]] || error "Aborted."

info "Partitioning with disko..."
nix run github:nix-community/disko -- --mode disko --flake ".#${TARGET_HOST}"

info "Installing NixOS..."
nixos-install --no-root-passwd --flake ".#${TARGET_HOST}"

DEST="/mnt/home/${INSTALL_USER}/nixos-server"
info "Copying flake to ${DEST}"
mkdir -p "$DEST"
rsync -a --delete --exclude result --exclude .git "${FLAKE_DIR}/" "$DEST/"
if [[ -n "${SUDO_UID:-}" ]]; then
  chown -R "${SUDO_UID}:${SUDO_GID:-$SUDO_UID}" "$DEST"
fi

success "Installed. Reboot, then: cd ~/nixos-server && just switch"
echo "  Login password is whatever you hashed in lib/me.nix (default: changeme)."
