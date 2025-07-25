{
  description = "Box64 Binfmt NixOS Module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    lib = nixpkgs.lib;
    supportedSystems = [ "aarch64-linux" "riscv64-linux" ];
    eachSystem = f: lib.genAttrs supportedSystems (system: f system);
    
    # Package sets for supported systems
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    
    overlay = final: prev: {
      x86 = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        # overlays = [
        #   (self: super: {
        #     mesa = super.mesa.override {
        #       # vulkanDrivers = [ "swrast" ];
        #       # swarast gave ERROR: Feature gallium-vdpau cannot be enabled: VDPAU state tracker requires at least one of the following gallium drivers: r600, radeonsi, nouveau, d3d12 (with option gallium-d3d12-video, virgl).
        #       # galliumDrivers = [ "llvmpipe" "softpipe" "nouveau" "virgl" ];

        #       vulkanDrivers = [
        #         "amd" # AMD (aka RADV)
        #         "intel" # new Intel (aka ANV)
        #         "microsoft-experimental" # WSL virtualized GPU (aka DZN/Dozen)
        #         "nouveau" # Nouveau (aka NVK)
        #         "swrast" # software renderer (aka Lavapipe)
        #       ];

        #       # https://nixos.wiki/wiki/Mesa
        #       # and
        #       # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/mesa/default.nix
        #       galliumDrivers =     [
        #         "d3d12" # WSL emulated GPU (aka Dozen)
        #         "iris" # new Intel (Broadwell+)
        #         "llvmpipe" # software renderer
        #         "nouveau" # Nvidia
        #         "r300" # very old AMD
        #         "r600" # less old AMD
        #         "radeonsi" # new AMD (GCN+)
        #         "softpipe" # older software renderer
        #         "svga" # VMWare virtualized GPU
        #         "virgl" # QEMU virtualized GPU (aka VirGL)
        #         "zink" # generic OpenGL over Vulkan, experimental
        #       ];
        #     };
        #   })
        # ];
      };
    };



  in {
    packages = eachSystem (system: {
      default = self.packages.${system}.box64-bleeding-edge;
      box64-bleeding-edge = (pkgsFor system).callPackage ./box64-bleeding-edge.nix {
        hello-x86_64 = if (pkgsFor system).stdenv.hostPlatform.isx86_64 then
          (pkgsFor system).hello
        else
          (pkgsFor system).pkgsCross.gnu64.hello;
      };
    });

    overlays = {
      default = overlay;
    };

     };
}
