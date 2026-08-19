{
  flake.modules.homeManager.core = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        scan_timeout = 200;
        command_timeout = 1000;
        format = "$all$character";
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        directory = {
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        git_branch.symbol = "🌱 ";
        nix_shell.symbol = "❄️ ";
      };
    };
  };
}
