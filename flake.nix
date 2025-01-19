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
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ emacs.overlay ]; };
    in
      {
        services.emacs.package = pkgs.emacs-unstable;

        packages.${system}.default =
          pkgs.emacsWithPackagesFromUsePackage {
            config = ./emacs.el;
            defaultInitFile = false;
            package = pkgs.emacs-unstable;
          };

        apps.${system}.default = {
          type = "app";
          program = "${pkgs.emacsWithPackagesFromUsePackage {
            config = ./emacs.el;
            defaultInitFile = false;
            package = pkgs.emacs-unstable;
          }}/bin/emacs";
        };

        # environment.systemPackages = [
        #       (pkgs.emacsWithPackagesFromUsePackage {
        #         config = ./emacs.el;
        #         package = pkgs.emacs-git;
        #         alwaysEnsure = true;
        #       })
        # ];


      };
}
