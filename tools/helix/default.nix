{
  self,
  lib,
  pkgs,
  nix-wrapper-modules,
}:
let
  yazi-wrapped = self.packages.${pkgs.stdenv.hostPlatform.system}.yazi-wrapped;
  lazygit-wrapped = self.packages.${pkgs.stdenv.hostPlatform.system}.lazygit-wrapped;
in
nix-wrapper-modules.wrappers.helix.wrap {
  inherit pkgs;

  settings = lib.importTOML ./config/config.toml // {
    theme = "catppuccin";
    keys.normal = {
      "C-y" = [
        ":set mouse false"
        ":insert-output if ('/tmp/helix_yazi_file_open' | path exists) { rm '/tmp/helix_yazi_file_open' }"
        '':insert-output ${lib.getExe yazi-wrapped} "%{buffer_name}" --chooser-file=/tmp/helix_yazi_file_open''
        ":insert-output if not ('/tmp/helix_yazi_file_open' | path exists) { '/tmp/helix_yazi_file_open' | save /tmp/helix_yazi_file_open }"
        ":redraw"
        ":set mouse true"
        ":open /tmp/helix_yazi_file_open"
        "select_all"
        "split_selection_on_newline"
        "goto_file"
        ":buffer-close! /tmp/helix_yazi_file_open"
      ];
      "C-g" = [
        ":write-all"
        ":new"
        ":insert-output ${lib.getExe lazygit-wrapped}"
        ":buffer-close!"
        ":redraw"
        ":reload-all"
      ];

    };
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
    yazi-wrapped
    lazygit-wrapped
    nufmt
    nixfmt
    deno
    prettier
    hyprls
    nixd
    nil
  ];
}
