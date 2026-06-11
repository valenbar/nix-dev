# A collection of nix templates for different dev environments

## set up dev env

```nu
nix flake init -t github:valenbar/nix-dev#<language>
```

## run tools defined here (like wrapped helix)

```nu
nix run github:valenbar/nix-dev#<package name>
```
