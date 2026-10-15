# myapp

- `nix develop` (or `direnv allow`): compiler, cmake, clangd, gdb
- `cmake -B build && cmake --build build && ./build/myapp`: build and run while developing
- `nix run`: build and run the package
- `nix flake check`: build the package
