{
  description = "Java template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # dependencies needed during build time
        nativeBuildInputs = with pkgs; [
          javaPackages.compiler.openjdk21
          jdt-language-server
        ];

        # things that need to be linked against eg. openssl, dbus
        buildInputs = with pkgs; [ ];
      in
      {
        devShells.default = pkgs.mkShell { inherit nativeBuildInputs buildInputs; };
      }
    );
}
