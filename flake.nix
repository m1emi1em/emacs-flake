{
  description = "m1emi1em's Emacs Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{self, nixpkgs, home-manager, emacs, ...}:
    let
      inherit (nixpkgs) lib;
      perSystem = lib.genAttrs ["x86_64-linux"];
    in
      {
        nixosModules = {
          default = self.nixosModules.emacs;
          emacs = {config, pkgs, ...}: {
            services.emacs.package = self.packages.${pkgs.system}.emacs;
            environment.systemPackages = [config.services.emacs.package];
          };
        };

        overlays = {
          default = self.overlays.emacs;
          emacs = emacs.overlay;
        };

        packages = perSystem (system: {
          default = self.packages.${system}.emacs;
          emacs = emacs.lib.${system}.emacsWithPackagesFromUsePackage {
            config = ./emacs.el;
            defaultInitFile = false;
            package = emacs.packages.${system}.emacs-unstable;
          };
        });

        apps = perSystem (system: {
          default = self.apps.${system}.emacs;
          emacs = {
            type = "app";
            program = "${self.packages.${system}.emacs}/bin/emacs";
          };
        });
      };
}
