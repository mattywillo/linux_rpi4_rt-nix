{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-compat }@inputs:
    let
      systems = nixpkgs.lib.platforms.linux;
      lib = nixpkgs.lib;
      packagePaths = rec {
        rpi4_rt_5_15 = ./packages/linux_rpi4_rt_5_15;
        rpi4_rt = rpi4_rt_5_15;
      };
    in rec {
      packages = lib.genAttrs systems (system:
        let
          pkgs = (lib.mapAttrs (n: v:
            lib.callPackageWith ((lib.recursiveUpdate packages.${system}
              nixpkgs.legacyPackages.${system}) // { inherit inputs; }) v { }) packagePaths);
        in (lib.mapAttrs' (n: v: lib.nameValuePair "linux_${n}" v) pkgs)
        // (lib.mapAttrs' (n: v: lib.nameValuePair "linuxPackages_${n}" v.linuxPackages) pkgs));
      legacyPackages = packages;
      overlay = final: prev:
        (lib.mapAttrs' (n: v: lib.nameValuePair "linux_${n}" (prev.callPackage v { raspberrypifw = prev.raspberrypifw; })) packagePaths)
        // (lib.mapAttrs' (n: v: lib.nameValuePair "linuxPackages_${n}" final."linux_${n}") packagePaths)
        // { raspberrypifw = final.linux_rpi4_rt.firmware; };
    };
}
