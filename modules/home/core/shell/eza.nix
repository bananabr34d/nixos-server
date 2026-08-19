{
  flake.modules.homeManager.core = {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
  };
}
