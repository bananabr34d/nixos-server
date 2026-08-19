# Turns the host list into real NixOS systems.
#
# A host file (modules/hosts/<name>/configuration.nix) does two things:
#   1. nixosHosts.<name> = { };          — "this machine exists"
#   2. flake.modules.nixos."nixosConfigurations/<name>" — "here is its config"
#
# This file is the factory: for each name it builds nixosConfigurations.<name>
# from the shared core plus that host module.
{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  options = {
    nixosHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.system = mkOption {
            type = types.str;
            default = "x86_64-linux";
          };
        }
      );
      default = { };
      description = "NixOS hosts this flake can build.";
    };
  };

  config = {
    flake.nixosConfigurations =
      let
        mkHost =
          hostname: options:
          inputs.nixpkgs.lib.nixosSystem {
            inherit (options) system;
            specialArgs.inputs = inputs;
            modules = [
              config.flake.modules.nixos.core
              (config.flake.modules.nixos."nixosConfigurations/${hostname}" or { })
            ];
          };
      in
      lib.mapAttrs mkHost config.nixosHosts;
  };
}
