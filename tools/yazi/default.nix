{
  lib,
  pkgs,
  nix-wrapper-modules,
}:
nix-wrapper-modules.wrappers.yazi.wrap {
  inherit pkgs;

  runtimePkgs = with pkgs; [
  ];

  constructFiles = {
    init = {
      relPath = "yazi-config/init.lua";
      content = /* lua */ ''
        require("git"):setup {
          order = 1500,
        }
      '';
    };
  };

  settings.yazi.plugin = {
    prepend_fetchers = [
      {
        url = "*";
        name = "*";
        run = "git";
        group = "git";
      }
      {
        url = "*/";
        name = "*/";
        run = "git";
        group = "git";
      }
    ];
  };

  plugins = {
    git = pkgs.yaziPlugins.git;
  };
}
