# Shared helpers for the primary/standby modules (not a NixOS module).
{
  config,
  pkgs,
  lib,
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.homelab;
  isPrimary = cfg.role == "primary";
  isStandby = cfg.role == "standby";
  host = config.networking.hostName;
  fqdn = "${host}.${cfg.tsDomain}";
  ntfyBase = "http://${cfg.primaryHost}.${cfg.tsDomain}:${toString cfg.monitoring.ntfyPort}";
  ntfyUrl = "${ntfyBase}/${cfg.monitoring.ntfyTopic}";

  ntfyPost = pkgs.writeShellScript "homelab-ntfy-post" ''
    set -euo pipefail
    title="''${1:-homelab on ${host}}"
    priority="''${2:-default}"
    tags="''${3:-}"
    body="$(${pkgs.coreutils}/bin/cat)"
    ${pkgs.curl}/bin/curl -sS --connect-timeout 5 --max-time 15 \
      -H "Title: $title" \
      -H "Priority: $priority" \
      ''${tags:+-H "Tags: $tags"} \
      -d "$body" \
      "${ntfyUrl}" >/dev/null || true
  '';

  smartdNtfyMailer = pkgs.writeShellScript "smartd-ntfy-mailer" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/cat | ${ntfyPost} "smartd on ${host}" high "warning,hdd"
  '';

  zpoolHealthCheck = pkgs.writeShellScript "homelab-zpool-health" ''
    set -euo pipefail
    export PATH="${config.boot.zfs.package}/bin:${pkgs.coreutils}/bin:$PATH"
    status="$(zpool status -x 2>&1 || true)"
    if echo "$status" | ${pkgs.gnugrep}/bin/grep -q "all pools are healthy"; then
      exit 0
    fi
    {
      echo "host: ${host}"
      echo "role: ${cfg.role}"
      echo
      echo "$status"
    } | ${ntfyPost} "zpool unhealthy on ${host}" urgent "rotating_light,zfs"
    exit 1
  '';

  syncoidFailureNotify = pkgs.writeShellScript "homelab-syncoid-failure-notify" ''
    set -euo pipefail
    unit="''${1:-unknown}.service"
    export PATH="${pkgs.systemd}/bin:${pkgs.coreutils}/bin:$PATH"
    result="$(systemctl show -p Result --value "$unit" 2>/dev/null || echo unknown)"
    logs="$(journalctl -u "$unit" -n 40 --no-pager 2>/dev/null || true)"
    {
      echo "host: ${host} (standby)"
      echo "unit: $unit"
      echo "result: $result"
      echo
      echo "$logs"
    } | ${ntfyPost} "syncoid FAILED: $unit on ${host}" urgent "x,zfs"
  '';
in
{
  inherit
    cfg
    isPrimary
    isStandby
    host
    fqdn
    ntfyBase
    ntfyUrl
    ntfyPost
    smartdNtfyMailer
    zpoolHealthCheck
    syncoidFailureNotify
    ;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
}
