{
  description = "Rust project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      cargoPackage = (nixpkgs.lib.importTOML ./Cargo.toml).package;
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          # Programs the binary calls at runtime; put on its PATH via a wrapper.
          runtimeDependencies = with pkgs; [ ];
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = cargoPackage.name;
            inherit (cargoPackage) version;

            src = nixpkgs.lib.fileset.toSource {
              root = ./.;
              fileset = nixpkgs.lib.fileset.unions [
                ./Cargo.toml
                ./Cargo.lock
                ./src
              ];
            };
            cargoLock.lockFile = ./Cargo.lock;

            nativeBuildInputs = with pkgs; [
              makeWrapper
              pkg-config
            ];
            # Libraries to link against, e.g. openssl, dbus
            buildInputs = with pkgs; [ ];

            postInstall = nixpkgs.lib.optionalString (runtimeDependencies != [ ]) ''
              wrapProgram $out/bin/${cargoPackage.name} \
                --prefix PATH : ${nixpkgs.lib.makeBinPath runtimeDependencies}
            '';

            passthru = { inherit runtimeDependencies; };
            meta.mainProgram = cargoPackage.name;
          };
        }
      );

      devShells = forAllSystems (
        pkgs:
        let
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          default = pkgs.mkShell {
            # cargo, rustc and the package's build inputs.
            inputsFrom = [ package ];
            packages =
              with pkgs;
              [
                clippy
                rustfmt
                rust-analyzer
                bacon
              ]
              ++ package.runtimeDependencies;

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };
        }
      );

      checks = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
