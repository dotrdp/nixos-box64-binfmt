# nixos-box64-binfmt
> [!NOTE]  
> This is in the most alpha version imaginable

Uses box64 to run x86_64 and i368 binaries in nixOS. Creates a proper FHS environment and can register binfmt entries to automatically run x86 binaries.
It provides its own `box64-bleeding-edge` package, with the bleeding edge changes and box32 support to run 32bit software (like `steam`) as well.

## Installation with flakes and Usage
*
Here's a minimal `flake.nix` demonstrating how to include the `nixos-box64-binfmt` module and its x86_64 package overlay:

```nix
# flake.nix
{
  description = "My NixOS Configuration with Box64 Binfmt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    box64-binfmt = {
      url = "github:Yeshey/nixos-box64-binfmt";
      # Optional: To ensure box64-binfmt uses the same Nixpkgs version as your system
      # inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, box64-binfmt, ... }@inputs: {
    nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      specialArgs = { inherit inputs; };

      modules = [
        # Import the Box64 Binfmt NixOS module
        inputs.box64-binfmt.nixosModules.default

        ./configuration.nix 
      ];
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.box64-binfmt.overlays.default  # Adds pkgs.x86
        ];
      };
    };
  };
}
```

Then, in your `configuration.nix` or equivelent:
```nix
# configuration.nix
{ pkgs, inputs, ... }:

{
  box64-binfmt.enable = true; # Enable 

  environment.systemPackages = [
    pkgs.x86.steamcmd          # SteamCMD for x86_64
    pkgs.x86.wineWowPackages.stable # WINE (WoW64 version)
    pkgs.x86.katawa-shoujo
    
    pkgs.htop                  # Native packages work as usual

    # This is the box64 version with box32 experimental support built, it is alrerady installed so this is not needed
    # inputs.box64-binfmt.packages.${pkgs.system}.box64-bleeding-edge
  ];
}
```

#### Todo
- GitHub action to auto update box64 according to the latest commits?
- Proper README
- Mechanism to install packages from other architectures, like `steam`, `steamcmd`, even when not supported? Maybe with `quemu`? Maybe under `pkgs.x86.<pkg>` if possible.
- `steam` is still not launching, see [this issue](https://github.com/ptitSeb/box64/issues/2478) to track it
