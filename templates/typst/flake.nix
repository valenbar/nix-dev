{
  description = "Typst document";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages =
            with pkgs;
            [
              typst
              typstyle
              tinymist

              # show preview inside a chromium window
              (writers.writeNuBin "preview" /* nu */ ''
                let url = "http://127.0.0.1:23635"
                setsid --fork ${lib.getExe chromium} --app $url out+err> /dev/null
              '')
            ]
            ++ (with typstPackages; [
              # Typst packages
            ]);
        };
      });
    };
}
