{
  description = "Java project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      # One JDK for building, running and the dev shell.
      jdkFor = pkgs: pkgs.jdk25_headless;
      mavenFor = pkgs: pkgs.maven.override { jdk_headless = jdkFor pkgs; };
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          jdk = jdkFor pkgs;
        in
        {
          default = (mavenFor pkgs).buildMavenPackage rec {
            pname = "myapp";
            version = "0.1.0";

            src = nixpkgs.lib.fileset.toSource {
              root = ./.;
              fileset = nixpkgs.lib.fileset.unions [
                ./pom.xml
                ./src
              ];
            };

            # Hash of all Maven dependencies and plugins. After changing them in
            # pom.xml, set this to "" and copy the hash from the error of `nix build`.
            mvnHash = "sha256-25UzKsZk/Ky+aB3I2gzRWoti2IodAq1zAbD6t4Zz/iw=";
            mvnJdk = jdk;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/${pname}
              cp target/${pname}.jar $out/share/${pname}/
              # Runtime dependencies (only exists once there are some)
              if [ -d target/lib ]; then cp -r target/lib $out/share/${pname}/; fi
              makeWrapper ${jdk}/bin/java $out/bin/${pname} \
                --add-flags "-jar $out/share/${pname}/${pname}.jar"
              runHook postInstall
            '';

            meta.mainProgram = pname;
          };
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (jdkFor pkgs)
            (mavenFor pkgs)
            pkgs.jdt-language-server # jdtls
            pkgs.google-java-format
          ];
        };
      });

      checks = forAllSystems (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
