{
  flake.modules.homeManager.core = {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        style = "compact";
        inline_height = 20;
        # Local history only. Turn on sync in this file if you want it.
        auto_sync = false;
        update_check = false;
      };
    };
  };
}
