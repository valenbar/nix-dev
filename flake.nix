{
  description = "Dev environment templates and preconfigured tools (helix, lazygit, yazi)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-helix = {
      url = "github:catppuccin/helix";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
      catppuccin-helix,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: f nixpkgs.legacyPackages.${system});

      # Shown after `nix flake init`.
      usage =
        {
          setup ? "",
          package ? false,
        }:
        ''
          ${setup}

          - `nix develop` / `direnv allow`: dev shell
        ''
        + nixpkgs.lib.optionalString package ''
          - `nix run`: build and run
          - `nix flake check`: build and test
        '';
    in
    {
      templates = {
        base = {
          path = ./templates/base;
          description = "Empty dev shell";
          welcomeText = usage { setup = "Add packages to `mkShell` in `flake.nix`."; };
        };
        python-shell = {
          path = ./templates/python/shell;
          description = "Python dev shell: interpreter + nixpkgs packages, nothing else";
          welcomeText = usage { setup = "Add dependencies to `withPackages` in `flake.nix`."; };
        };
        python-app = {
          path = ./templates/python/app;
          description = "Python app: dev shell + package for nix run/flake check, from pyproject.toml";
          welcomeText = usage {
            setup = ''
              Rename the package in `pyproject.toml` (`name`, `[project.scripts]`) and `src/mypackage/`.
              Add dependencies to `pyproject.toml`; they are resolved from nixpkgs.
            '';
            package = true;
          };
        };
        cpp = {
          path = ./templates/cpp;
          description = "C/C++ (CMake): dev shell + package for nix run/flake check";
          welcomeText = usage {
            setup = "Rename `myapp` in `CMakeLists.txt` and `flake.nix`. Libraries go in `buildInputs`.";
            package = true;
          };
        };
        rust = {
          path = ./templates/rust;
          description = "Rust: dev shell + package for nix run/flake check, from Cargo.toml";
          welcomeText = usage {
            setup = "Rename the package in `Cargo.toml`, then run `cargo generate-lockfile`.";
            package = true;
          };
        };
        java = {
          path = ./templates/java;
          description = "Java (Maven): dev shell + package for nix run/flake check, JUnit tests";
          welcomeText = usage {
            setup = ''
              Rename `myapp` in `pom.xml`, `flake.nix` and the `src/` package path.
              After changing dependencies in `pom.xml`, set `mvnHash = ""` and copy the hash from `nix build`.
            '';
            package = true;
          };
        };
        nushell = {
          path = ./templates/nushell;
          description = "Nushell: dev shell + script package, optional Jupyter kernel";
          welcomeText = usage {
            setup = "Write the script in `main.nu`. Set `enableJupyter = true` in `flake.nix` for notebooks.";
            package = true;
          };
        };
        typst = {
          path = ./templates/typst;
          description = "Typst document: compiler, formatter, tinymist LSP + live preview";
          welcomeText = usage {
            setup = "Write in `main.typ`. In helix, `C-p` pins the main file; run `preview` for a live preview.";
          };
        };
      };

      packages = forAllSystems (
        pkgs:
        let
          tools = {
            lazygit-wrapped = pkgs.callPackage ./tools/lazygit { };
            yazi-wrapped = pkgs.callPackage ./tools/yazi { inherit nix-wrapper-modules; };
            helix-wrapped = pkgs.callPackage ./tools/helix {
              inherit nix-wrapper-modules catppuccin-helix;
              inherit (tools) yazi-wrapped lazygit-wrapped;
            };
          };
        in
        tools
        // {
          # All tools at once: `nix profile install github:valenbar/nix-dev`.
          # `nix run github:valenbar/nix-dev` opens helix.
          default = pkgs.buildEnv {
            name = "nix-dev-tools";
            paths = builtins.attrValues tools;
            meta.mainProgram = "hx";
          };

          nu-jupyter-kernel = pkgs.callPackage ./pkgs/nu-jupyter-kernel/package.nix { };
        }
      );

      # `nix flake check` builds every package.
      checks = forAllSystems (pkgs: self.packages.${pkgs.stdenv.hostPlatform.system});

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
