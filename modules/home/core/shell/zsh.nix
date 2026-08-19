{
  flake.modules.homeManager.core =
    { config, lib, ... }:
    {
      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        envExtra = ''
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
              . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi
        '';

        shellAliases = {
          cat = "bat";
          ".." = "cd ..";
          "..." = "cd ../..";
          l = lib.mkForce "eza -lhg --icons --group-directories-first";
          la = lib.mkForce "eza -lahg --icons --group-directories-first";
          ll = lib.mkForce "eza -lahg --icons --group-directories-first --git";
          cp = "cp -i";
          mv = "mv -i";
          rm = "rm -i";
          mkdir = "mkdir -p";
          vi = "hx";
          gst = "git status -sb";
          lg = "lazygit";
          neofetch = "fastfetch";
          tst = "tailscale status";
          nrb = "nh os switch . --hostname $(hostname -s)";
          nfu = "nix flake update";
          nfc = "nix flake check";
          pull-switch = "just pull-switch";
          gc = "nh clean all --keep 5";
        };

        history = {
          size = 100000;
          save = 100000;
          path = "${config.xdg.dataHome}/zsh/history";
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
          extended = true;
        };

        initContent = ''
          setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
          setopt CORRECT INTERACTIVE_COMMENTS NO_BEEP EXTENDED_GLOB
          bindkey -e
          [[ -f "${config.xdg.configHome}/zsh/local.zsh" ]] && source "${config.xdg.configHome}/zsh/local.zsh"
        '';
      };

      home.file."${config.xdg.dataHome}/zsh/.keep".text = "";
    };
}
