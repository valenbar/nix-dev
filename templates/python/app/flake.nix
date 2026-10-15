{
  description = "Python project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pyproject-nix,
    }:
    let
      # pyproject.toml is the single source of truth: name, version, dependencies,
      # scripts, dependency groups. Dependencies are resolved from nixpkgs.
      project = pyproject-nix.lib.project.loadPyproject { projectRoot = ./.; };

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      pythonFor = pkgs: pkgs.python3;
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          python = pythonFor pkgs;
          attrs = project.renderers.buildPythonPackage { inherit python; };
        in
        {
          default = python.pkgs.buildPythonApplication (
            attrs
            // {
              # Only rebuild when these change (not on README/flake.nix edits).
              src = nixpkgs.lib.fileset.toSource {
                root = ./.;
                fileset = nixpkgs.lib.fileset.unions [
                  ./pyproject.toml
                  ./src
                  ./tests
                ];
              };

              nativeCheckInputs = [ python.pkgs.pytestCheckHook ] ++ attrs.passthru.dependency-groups.dev;
            }
          );
        }
      );

      devShells = forAllSystems (
        pkgs:
        let
          python = pythonFor pkgs;

          # The project itself, installed in editable mode: code changes are live
          # and the [project.scripts] entry points are on PATH.
          editable = python.pkgs.mkPythonEditablePackage (
            project.renderers.mkPythonEditablePackage {
              inherit python;
              root = "$REPO_ROOT/src";
            }
          );

          pythonEnv = python.withPackages (
            project.renderers.withPackages {
              inherit python;
              groups = [ "dev" ];
              # Inside the env so the LSP sees the project's dependencies.
              extraPackages = ps: [
                editable
                ps.python-lsp-server
              ];
            }
          );
        in
        {
          default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.ruff
            ];
            shellHook = ''
              export REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
            '';
          };
        }
      );

      checks = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
