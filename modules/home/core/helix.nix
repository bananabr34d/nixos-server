# Helix is the default editor. Desktops override the theme to "noctalia".
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prettier ];

      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "catppuccin_mocha";
          editor = {
            line-number = "relative";
            cursorline = true;
            color-modes = true;
            soft-wrap = {
              enable = true;
              max-wrap = 0;
              wrap-indicator = "";
            };
            file-picker.hidden = false;
          };
          keys.normal.space.m.p = [
            '':sh glow -p "%{buffer_name}"''
            ":redraw"
          ];
        };
        languages = {
          language = [
            {
              name = "markdown";
              language-servers = [ "marksman" ];
              auto-format = true;
              formatter = {
                command = "prettier";
                args = [
                  "--parser"
                  "markdown"
                ];
              };
            }
          ];
          language-server.marksman = {
            command = "marksman";
            args = [ "server" ];
          };
        };
      };
    };
}
