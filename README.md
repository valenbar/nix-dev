# nix-dev

Dev environment templates and preconfigured tools.

## Templates

```sh
nix flake init -t github:valenbar/nix-dev#<template>
```

| Template | What you get |
|---|---|
| `base` | Empty dev shell |
| `python-shell` | Python + packages from nixpkgs, nothing else |
| `python-app` | Python project driven by `pyproject.toml`: dev shell, `nix run`, tests |
| `cpp` | C/C++ with CMake: dev shell, `nix run` |
| `rust` | Rust with Cargo: dev shell, `nix run` |
| `java` | Java with Maven: dev shell, `nix run`, JUnit tests |
| `nushell` | Nushell script: dev shell, `nix run`, optional Jupyter kernel |
| `typst` | Typst document: compiler, LSP, live preview |

Templates with a package also ship a GitHub Actions workflow running `nix flake check`.

## Tools

Preconfigured helix, lazygit and yazi, usable on any machine with Nix:

```sh
nix run github:valenbar/nix-dev                  # helix
nix run github:valenbar/nix-dev#lazygit-wrapped
nix profile install github:valenbar/nix-dev      # all tools
```

| Package | |
|---|---|
| `default` | helix, lazygit and yazi together; `nix run` opens helix |
| `helix-wrapped` | helix with config, theme, LSPs/formatters, `C-y` yazi picker, `C-g` lazygit |
| `lazygit-wrapped` | lazygit with config and theme |
| `yazi-wrapped` | yazi with the git plugin |
| `nu-jupyter-kernel` | Jupyter kernel for Nushell, used by the `nushell` template |

`nix flake show github:valenbar/nix-dev` lists everything.
