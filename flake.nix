{
  description = "Omega's NixOS environment.";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/release-21.11";
    digga = {
      url = "github:divnix/digga";
      inputs.nixpkgs.follows = "nixos";
    };
    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixos";
  };

  outputs = inputs @ {
    self,
    nixos,
    digga,
    home,
  }:
    digga.lib.mkFlake {
      inherit self inputs;

      channels.nixos = {};

      nixos = let
        inherit (inputs.digga.lib) allProfilesTest;
      in {
        imports = [(digga.lib.importHosts ./hosts)];
        hostDefaults.channelName = "nixos";
        importables = rec {
          suites = rec {
            base = [];
          };
        };
      };
      home = let
        name = "Omega Dilebo";
        email = "omega.meseret@iohk.io";
        gitSigningKey = "0318D822BAC965CC";
      in {
        imports = [(digga.lib.importExportableModules ./home/modules)];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./home/profiles;
          suites = {
            shell = builtins.attrValues profiles.shell;
          };
        };
        users.omega = {suites, ...}: {
          imports = suites.shell;
          programs.git = {
            userName = name;
            userEmail = email;
            # signing = {
            #  key = gitSigningKey;
            #  signByDefault = true;
            # };
          };
        };
      };
    };
}
