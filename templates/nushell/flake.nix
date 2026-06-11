{
  description = "Nushell template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # adjust as needed
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
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jupyter
            nix-dev.packages.${system}.nu-jupyter-kernel
          ];

          shellHook = ''
            echo "Run 'nu-jupyter-kernel --register' to register the Nushell kernel"
          '';
        };

        packages.default = pkgs.writers.writeNuBin "my-nu-script.nu" ./main.nu;
      }
    );
}
