{
  lib,
  pkgs,
  nix-wrapper-modules,
  catppuccin-helix,
  yazi-wrapped,
  lazygit-wrapped,
}:
let
  # Per-instance file for yazi's chosen paths (exported by the wrapper below),
  # so two helix instances never share it. Read via nu, the configured shell.
  chooser = "$env.HELIX_YAZI_CHOOSER";
in
nix-wrapper-modules.wrappers.helix.wrap {
  inherit pkgs;

  settings = lib.importTOML ./config/config.toml // {
    theme = "catppuccin";
    keys.normal = {
      "C-y" = [
        ":set mouse false"
        ":insert-output rm -f ${chooser}"
        '':insert-output ${lib.getExe yazi-wrapped} "%{buffer_name}" $"--chooser-file=(${chooser})"''
        ":insert-output if not (${chooser} | path exists) { ${chooser} | save ${chooser} }"
        ":redraw"
        ":set mouse true"
        ":open %sh{${chooser}}"
        "select_all"
        "split_selection_on_newline"
        "goto_file"
        ":buffer-close! %sh{${chooser}}"
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

  languages = lib.recursiveUpdate (lib.importTOML ./config/languages.toml) {
    # nixpkgs option completion, pinned to the nixpkgs this helix is built from
    language-server.nixd.config.nixd.options.nixpkgs.expr = "import ${pkgs.path} { }";
  };

  themes.catppuccin = lib.importTOML "${catppuccin-helix}/themes/default/catppuccin_mocha.toml";

  runShell = [
    ''export HELIX_YAZI_CHOOSER="$(${pkgs.coreutils}/bin/mktemp -u -t helix-yazi.XXXXXX)"''
  ];

  runtimePkgs = with pkgs; [
    yazi-wrapped
    lazygit-wrapped
    nushell # editor.shell and the C-y binding run through nu
    vscode-langservers-extracted # json, css
    nufmt
    nixfmt
    deno
    prettier
    hyprls
    nixd
    nil
  ];
}
