{
  self,
  lib,
  pkgs,
  nix-wrapper-modules,
}:
nix-wrapper-modules.wrappers.helix.wrap {
  inherit pkgs;

  settings = lib.importTOML ./config/config.toml // {
    theme = "catppuccin";
  };

  languages = lib.importTOML ./config/languages.toml;

  themes =
    let
      catppuccin-helix = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "helix";
        rev = "91e071bf9b9b2b8ae176a5581fcb61c789c55cab";
        sha256 = "sha256-F05ohJp7c9Pdnjq8+srfhAt1ogHjjBz50k1ftHOHGVg=";
      };
      flavor = "mocha";
    in
    {
      catppuccin = fromTOML (
        builtins.readFile "${catppuccin-helix}/themes/default/catppuccin_${flavor}.toml"
      );
    };

  runtimePkgs = with pkgs; [
    self.packages.${pkgs.stdenv.hostPlatform.system}.yazi-wrapped
    nufmt
    nixfmt
    deno
    prettier
    hyprls
    nixd
    nil
  ];
}
