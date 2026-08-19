topLevel: {
  flake.modules.nixos.dev =
    { ... }:
    {
      imports = with topLevel.config.flake.modules.nixos; [
        home-manager
      ];
    };
}
