{
  description = "Omega's NixOS Devshell";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.deploy.url = "github:input-output-hk/deploy-rs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = inputs:
    inputs.flake-utils.lib.eachSystem ["x86_64-linux" "x86_64-darwin"] (
      system: let
        pkgWithCategory = category: package: {inherit package category;};
        utils = pkgWithCategory "utils";
        docs = pkgWithCategory "docs";
        devos = pkgWithCategory "devos";
      in {
        devShells.default = inputs.devshell.legacyPackages.${system}.mkShell (
          {
            extraModulesPath,
            pkgs,
            ...
          }: {
            name = "NixOS Config";
            packages = with inputs.nixpkgs.legacyPackages.${system}; [
              # treefmt.toml deps
              alejandra
              nodePackages.prettier
              shfmt
              # pre-commit-check
              editorconfig-checker
            ];

            commands = with inputs.nixpkgs.legacyPackages.${system}; [
              (docs mdbook)
              (devos inputs.deploy.packages.${system}.deploy-rs)
              (utils treefmt)
            ];

            imports = [
            ];
          }
        );
      }
    );
}
