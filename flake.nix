{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld-rs = {
      url = "github:nix-community/nix-ld-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      extraLib = {
        callPackageWith =
          overrides: path:
          let
            f = import path;
          in
          f (
            (builtins.intersectAttrs (builtins.functionArgs f) (
              {
                inherit inputs;
                inherit extraLib;
              }
              // pkgs
              // overrides
            ))
          );
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;
      nixosConfigurations = {
        WS1061 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit extraLib;
          };
          modules = [ ./hosts/WS1061 ];
        };
      };
    };
}
