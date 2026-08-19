{
  flake.modules.homeManager.core =
    { lib, pkgs, ... }:
    let
      me = import ../../../lib/me.nix;
    in
    {
      home = {
        username = lib.mkDefault me.username;
        homeDirectory = lib.mkDefault "/home/${me.username}";
        packages = with pkgs; [
          bat
          bottom
          fd
          fzf
          htop
          nil
          lazygit
          ripgrep
          tmux
          fastfetch
        ];
        sessionVariables = {
          EDITOR = "hx";
          VISUAL = "hx";
        };
      };

      programs.bat.enable = true;

      programs.git = {
        enable = lib.mkDefault true;
        settings = {
          user.name = lib.mkDefault me.fullName;
          user.email = lib.mkDefault me.email;
        };
      };
    };
}
