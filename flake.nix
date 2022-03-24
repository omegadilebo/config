{
  description = "Omega's NixOS environment.";

  inputs = {
    nix.url = "github:kreisys/nix/goodnix-maybe-dont-functor";
    nixos.url = "github:nixos/nixpkgs/release-21.11";
    digga = {
      url = "github:divnix/digga";
      inputs.nixpkgs.follows = "nixos";
    };
    # home.url = "github:nix-community/home-manager/release-21.11";
    home.url = "github:blaggacao/home-manager/release-21.11-with-nix-profile";
    home.inputs.nixpkgs.follows = "nixos";
    deploy.follows = "digga/deploy";
  };

  outputs = inputs @ {
    self,
    nixos,
    digga,
    home,
    deploy,
    ...
  }:
    digga.lib.mkFlake {
      inherit self inputs;

      deploy.nodes =
        digga.lib.mkDeployNodes self.nixosConfigurations
        {
          blacklion = {
            profilesOrder = ["system" "omega"];
            profiles.omega = {
              user = "omega";
              path = deploy.lib.x86_64-linux.activate.home-manager self.homeConfigurationsPortable.x86_64-linux.omega;
            };
          };
        };

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
