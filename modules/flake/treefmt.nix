# nixfmt + deadnix + statix via treefmt. `nix fmt` / `just format`.
# flakeCheck = true → `nix flake check` fails if the tree is dirty.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    flakeCheck = true;
    programs = {
      nixfmt.enable = true;
      deadnix = {
        enable = true;
        no-lambda-pattern-names = true;
      };
      statix.enable = true;
    };
  };
}
