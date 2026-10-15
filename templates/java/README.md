# myapp

- `nix develop` (or `direnv allow`): JDK, Maven, jdtls, google-java-format
- `mvn package && java -jar target/myapp.jar`: build, test and run while developing
- `nix run`: build and run the package
- `nix flake check`: build and test

After changing dependencies or plugins in `pom.xml`, set `mvnHash = ""` in `flake.nix`,
run `nix build` and copy the hash from the error.
