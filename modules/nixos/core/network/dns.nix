{
  flake.modules.nixos.dns =
    { lib, options, ... }:
    {
      # systemd-resolved owns DNS (127.0.0.53).
      #
      # Split DNS: apps talk to resolved; each link brings its own upstream
      # (DHCP/LAN on Wi-Fi/Ethernet, MagicDNS on tailscale0). Do not set
      # networking.nameservers here — a global list fights per-link DNS and
      # is a common source of "Tailscale names work, the internet does not."
      #
      # In the Tailscale admin console leave "Override local DNS" off.
      services.resolved =
        {
          enable = true;
        }
        // lib.optionalAttrs (options.services.resolved ? settings) {
          settings.Resolve = {
            FallbackDNS = [
              "1.1.1.1"
              "8.8.8.8"
            ];
          };
        }
        // lib.optionalAttrs (!(options.services.resolved ? settings)) {
          fallbackDns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
    };
}
