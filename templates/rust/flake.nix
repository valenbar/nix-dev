{
  description = "Rust template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # dependencies needed in path during runtime
        runtimeDependencies = with pkgs; [ ];

        # dependencies needed during build time
        nativeBuildInputs = with pkgs; [
          makeWrapper
          pkg-config
        ];

        # things that need to be linked against eg. openssl, dbus
        buildInputs = with pkgs; [ ];

        cargo_package = (fromTOML (builtins.readFile ./Cargo.toml)).package;
        pname = cargo_package.name;
        version = cargo_package.version;
      in
      {
        devShells.default = pkgs.mkShell {
          packages =
            with pkgs;
            [
              cargo
              rustc
              rustfmt
              rustPackages.clippy
              bacon
              rust-analyzer
            ]
            ++ nativeBuildInputs
            ++ runtimeDependencies;

          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };

        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          inherit
            pname
            version
            buildInputs
            nativeBuildInputs
            ;

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          # wrap binary to include runtime dependencies in path
          postInstall = ''
            wrapProgram $out/bin/${pname} \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDependencies}
          '';

          meta = {
            description = "";
            homepage = "";
            license = [ ];
            mainProgram = pname;
          };
        };

      }
    );
}
