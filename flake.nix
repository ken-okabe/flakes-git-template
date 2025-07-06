{
  description = "A declarative NixOS system configuration using Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    hostname = "nixos";
    system = "x86_64-linux";
    stateVersion = "25.05";
    
    username = "USERNAME"; # Replace with your actual username
    passwordHash = "PASSWORD_HASH"; # Replace with your actual password hash 
    
    gitUsername = "GIT_USERNAME"; # Replace with your actual git username
    gitUseremail = "GIT_USEREMAIL"; # Replace with your actual git user email
  in
  {
    nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
      system = system;

      specialArgs = { # These are NixOS system-wide specialArgs, available to all NixOS modules
        hostname = hostname;
        system = system;
        stateVersion = stateVersion;

        username = username;
        passwordHash = passwordHash;
        gitUsername = gitUsername;
        gitUseremail = gitUseremail;
      };
      
      modules = [
        # System state version
        {
          system.stateVersion = stateVersion; # Did you read the comment?
        }
        # Import the Home Manager NixOS module first
        home-manager.nixosModules.home-manager
        # Then import your home configuration module
        ./sub/home.nix
        # Import other necessary system-wide modules
        ./sub/hardware-configuration.nix
        ./sub/boot.nix
        ./sub/user.nix # System-wide user settings
        ./sub/gnome-desktop.nix
        ./sub/key-remap.nix
        ./sub/system-packages.nix
        ./sub/system-settings.nix

      ];
    };
  };
}
