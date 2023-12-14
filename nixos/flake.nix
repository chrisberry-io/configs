{
  description = "Chris Berry's NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      #pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          # specialArgs = { inherit inputs outputs pkgs-unstable; };
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.chris = import ./home-manager/home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
      };
    };
}
