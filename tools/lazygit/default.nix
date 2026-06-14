{
  pkgs,
  ...
}:
pkgs.symlinkJoin {
  name = "lazygit";
  paths = [ pkgs.lazygit ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/lazygit \
      --set CONFIG_DIR "/tmp/lazygit" \
      --add-flags "--use-config-file=${./config/config.yaml},${./config/theme.yaml}"
  '';
  meta.mainProgram = "lazygit";
}
