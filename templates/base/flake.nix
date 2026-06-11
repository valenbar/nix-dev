{
  description = "Base template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-dev.url = "github:valenbar/nix-dev";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-dev,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # nix-dev.packages.${system}.helix-wrapped
          ];
        };
      }
    );
}
