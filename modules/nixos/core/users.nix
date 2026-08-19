{
  flake.modules.nixos.users =
    { pkgs, ... }:
    let
      me = import ../../../lib/me.nix;
    in
    {
      programs.zsh.enable = true;

      users = {
        defaultUserShell = pkgs.zsh;
        # Accounts come from this file, not from `passwd` on the machine.
        # That way two installs of the same flake look the same.
        mutableUsers = false;

        users = {
          root = {
            isSystemUser = true;
            hashedPassword = me.hashedPassword;
          };

          ${me.username} = {
            isNormalUser = true;
            uid = 1000;
            description = me.fullName;
            extraGroups = [ "wheel" ];
            hashedPassword = me.hashedPassword;
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = me.extraSshKeys;
          };
        };
      };
    };
}
