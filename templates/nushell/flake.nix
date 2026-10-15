{
  description = "Nushell project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Provides nu-jupyter-kernel (only used when enableJupyter = true).
    nix-dev = {
      url = "github:valenbar/nix-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-dev,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      enableJupyter = false;
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.writers.writeNuBin "my-script" ./main.nu;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.nushell
          ]
          ++ pkgs.lib.optionals enableJupyter [
            pkgs.jupyter
            nix-dev.packages.${pkgs.stdenv.hostPlatform.system}.nu-jupyter-kernel
          ];

          shellHook = pkgs.lib.optionalString enableJupyter ''
            echo "Run 'nu-jupyter-kernel --register' to register the Nushell kernel"
          '';
        };
      });

      checks = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
