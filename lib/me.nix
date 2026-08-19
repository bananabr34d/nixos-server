# You and this pair of machines. Change this file first.
#
# Password hash below is the word "changeme". Replace it before the
# servers face a network:  mkpasswd -m yescrypt
{
  username = "alice";
  fullName = "Alice";
  email = "alice@example.com";

  hashedPassword = "$y$j9T$7WbivV5iBfASrIHP9sISc.$3/r7U88jNOluYZv6pi7IjNMyMKzRu3w/fbup9JQc1T4";

  extraSshKeys = [
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... alice@laptop"
  ];

  timeZone = "America/Chicago";
  locale = "en_US.UTF-8";

  # Hostname of the live server (syncoid source, cache name, Caddy).
  primaryHost = "primary";

  # From `tailscale status` / the admin console. HTTPS names become
  #   ${hostname}.${tsDomain}
  # Example: "tailnet-name.ts.net"
  tsDomain = "example.ts.net";
}
