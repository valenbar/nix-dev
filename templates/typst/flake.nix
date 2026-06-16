{
  description = "Typst template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-dev.url = "github:valenbar/nix-dev";
  };

  outputs =
    { ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          packages =
            with pkgs;
            [
              typst
              typstyle
              tinymist
              inputs.nix-dev.packages.${system}.helix-wrapped

              # show preview inside a chromium window
              (pkgs.writers.writeNuBin "preview" /* nu */ ''
                let url = "http://127.0.0.1:23635"
                setsid --fork ${lib.getExe pkgs.chromium} --app $url out+err> /dev/null
              '')
            ]
            ++ (with typstPackages; [
              # Typst packages
            ]);
        };
      }
    );
}
