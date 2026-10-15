{
  description = "C/C++ project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        # Use pkgs.clangStdenv.mkDerivation to build with clang instead of gcc.
        default = pkgs.stdenv.mkDerivation {
          pname = "myapp";
          version = "0.1.0";

          src = nixpkgs.lib.fileset.toSource {
            root = ./.;
            fileset = nixpkgs.lib.fileset.unions [
              ./CMakeLists.txt
              ./src
            ];
          };

          nativeBuildInputs = [ pkgs.cmake ];
          # Libraries to link against, e.g. pkgs.fmt
          buildInputs = [ ];

          meta.mainProgram = "myapp";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Same compiler, cmake and libraries as the package.
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          packages = [
            pkgs.clang-tools # clangd, clang-format
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.gdb ];
        };
      });

      checks = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
