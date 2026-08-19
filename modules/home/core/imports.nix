{ config, ... }:
{
  flake.modules.homeManager.core.imports = [
    config.flake.modules.homeManager.home-manager
  ];
}
