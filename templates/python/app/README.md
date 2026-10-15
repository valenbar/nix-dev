# mypackage

- `nix develop` (or `direnv allow`): Python with all dependencies, the project installed in editable mode, ruff, pytest
- `nix run`: build and run the `mypackage` script
- `nix flake check`: build the package and run the tests

Dependencies are declared in `pyproject.toml` only and resolved from nixpkgs.
