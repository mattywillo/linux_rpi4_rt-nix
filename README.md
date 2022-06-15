# Raspberry Pi 4 PREEMPT_RT Kernel for NixOS
This flake provides packages to build the [Raspberry Pi supplied kernel](https://github.com/raspberrypi/linux) with `PREEMPT_RT` enabled.

### Usage
Add the overlay and set `boot.kernelPackages` to `pkgs.linuxPackages_rpi4_rt`

An example flake based system config with `boot.loader.raspberryPi` and `nixos-hardware`:

``` nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    rpi4_rt.url = "github:mattywillo/linux_rpi4_rt-nix";
  };
  outputs = { self, nixpkgs, nixos-hardware, rpi4_rt }: {
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      modules = [ 
        ({pkgs, lib, ...}: { 
          nixpkgs.overlays = [ rpi4_rt.overlay ]; 
          
          imports = [
            ./hardware-configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
          ];

          boot.kernelPackages = pkgs.linux_rpi4_rt.linuxPackages;

          boot.loader.grub.enable = false;
          boot.loader.grub.device = "nodev";

          # Recent NixOS versions enforce uniqueness on installBootLoader
          # making nixos-hardware.raspberry-pi-4' and 'boot.loader.raspberryPi'
          # conflict, this line prevents nixos-hardware setting the bootloader
          boot.loader.generic-extlinux-compatible.enable = lib.mkForce false;

          boot.loader.raspberryPi.enable = true;
          boot.loader.raspberryPi.version = 4;
          
          #...regular system configuration...
        }) 
      ];
    };
  };
}
```
