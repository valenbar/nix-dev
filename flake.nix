{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      templates = {
        python = {
          path = ./templates/python;
        };
        rust = {
          path = ./templates/rust;
        };
        nushell = {
          path = ./templates/nushell;
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          lazygit-wrapped = pkgs.callPackage ./tools/lazygit { inherit pkgs; };
          helix-wrapped = pkgs.callPackage ./tools/helix { inherit pkgs nix-wrapper-modules; };

          nu-jupyter-kernel = pkgs.callPackage ./pkgs/nu-jupyter-kernel/package.nix { };
        }
      );
    };
}
