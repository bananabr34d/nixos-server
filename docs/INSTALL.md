# Install

Disko **wipes every disk listed** for that host. Confirm by-id paths
on the live ISO. If you already have a ZFS tank with photos on it,
do not put those disks in `disko.devices` — see "Existing tank" below.

## 0. Before you boot the ISO

1. Edit `lib/me.nix`: username, password hash (`mkpasswd -m yescrypt`),
   SSH keys, `timeZone`, `tsDomain` (from the Tailscale admin console),
   `primaryHost` (default `primary`).
2. Generate a unique `networking.hostId` per machine and put it in
   that host's `disko.nix`:

   ```bash
   head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
   ```

   Keep it forever. ZFS uses it to know who last imported the pool.

3. On the live ISO:

   ```bash
   ls -l /dev/disk/by-id/ | grep -iE 'nvme|ata'
   ```

   Replace every `REPLACE-ME` in `modules/hosts/<name>/disko.nix`.

## 1. Install

Any current NixOS ISO. Network via DHCP is enough on these hosts
(no NetworkManager).

```bash
cd /path/to/nixos-server
sudo ./scripts/install-system.sh primary    # or standby
```

Type the hostname to confirm. After reboot, log in as the user in
`lib/me.nix` (default password word: `changeme` — change it).

## 2. Tailscale

On each server:

```bash
sudo tailscale up
```

In the admin console: enable **MagicDNS** and **HTTPS certificates**.
Leave **Override local DNS** off.

Set `lib/me.nix` `tsDomain` to the suffix `tailscale status` shows
(e.g. `something.ts.net`). `just switch` again so Caddy's site name
matches.

## 3. First apps on primary

- Immich: `http://primary:2283` then `https://primary.<tsDomain>/`
- Forgejo: `http://primary:3000` then `https://primary.<tsDomain>/git/`
- ntfy: `http://primary.<tsDomain>:2586/homelab` (phone app)

Samba: `sudo smbpasswd -a <username>` once, then
`smb://primary/documents` on the LAN. Time Machine is the
`TimeMachine` share (macOS Finder, same password).

## 4. Syncoid (standby pulls)

On **standby**:

```bash
sudo -u syncoid ssh-keygen -t ed25519 -N "" -C syncoid@standby \
  -f /var/lib/syncoid/.ssh/id_ed25519
sudo cat /var/lib/syncoid/.ssh/id_ed25519.pub
```

On **primary**, put that line in `homelab.syncoidPubKey` and switch.
Then allow ZFS send for that user:

```bash
sudo zfs allow -u syncoid send,hold,bookmark,snapshot tank/immich
sudo zfs allow -u syncoid send,hold,bookmark,snapshot tank/forgejo
sudo zfs allow -u syncoid send,hold,bookmark,snapshot tank/documents
```

On **standby**, test:

```bash
sudo -u syncoid ssh syncoid@primary 'zfs list -r tank/immich'
sudo systemctl start syncoid-immich.service
journalctl -u syncoid-immich -n 50
```

## 5. Harmonia (optional)

Only after you are comfortable with sops:

```bash
sudo age-keygen -o /var/lib/sops-nix/key.txt
nix-store --generate-binary-cache-key primary /tmp/secret /tmp/public
# sops-encrypt /tmp/secret as harmonia_key
# add /tmp/public to nix.settings.trusted-public-keys on every host
```

Import `sops-nix` + `modules/nixos/core/sops.nix` from the host (or
from `core/imports.nix`), set `homelab.cache.enable = true`, and
declare `sops.secrets.harmonia_key` on primary (the host file has a
commented example). Switch primary. From a fast Linux box:

```bash
just push-cache primary standby
```

Slow boxes then `just pull-switch` and mostly download.

## Existing tank

If the data disks already hold a pool you need:

1. Remove `data1` / `data2` from that host's `disko.nix`.
2. Install with only the OS NVMe attached (or listed).
3. After boot: `sudo zpool import tank` (once: `-f` if the old
   machine died uncleanly).
4. Declare the same `/data/...` mounts as `fileSystems` entries
   (`device = "tank/immich"; fsType = "zfs";`).

Never let disko "create" a pool that already exists.

## If something is wrong

```bash
just generations
sudo nixos-rebuild --rollback switch
```

Standby with apps suddenly on → turn them off, figure out who wrote
what, do not "just promote" in a panic. See [ROLES.md](ROLES.md).
