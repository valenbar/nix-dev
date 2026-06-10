{
  description = "A very basic flake";

  outputs =
    { self }:
    {
      templates = {
        python = {
          path = ./templates/python;
        };

        rust = {
          path = ./templates/rust;
        };

        java = {
          path = ./templates/java;
        };
      };

    };
}
