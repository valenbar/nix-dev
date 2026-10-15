{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  fontconfig,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu-jupyter-kernel";
  version = "0.1.15+0.111.0";

  src = fetchFromGitHub {
    owner = "cptpiepmatz";
    repo = "nu-jupyter-kernel";
    tag = "nu-jupyter-kernel/v${finalAttrs.version}";
    hash = "sha256-hBMmIJYRUs5fDPLYxVhfpiQHShZV4uj/o+DRuQsCIjk=";
  };

  cargoHash = "sha256-GLCK345ADX0YRBpdy0FLonow/9CM2/g/fIJO/lOX3r8=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [ fontconfig ];

  meta = {
    description = "Jupyter kernel for nu";
    homepage = "https://github.com/cptpiepmatz/nu-jupyter-kernel";
    changelog = "https://github.com/cptpiepmatz/nu-jupyter-kernel/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      mit
    ];
    platforms = lib.platforms.all;
  };
})
