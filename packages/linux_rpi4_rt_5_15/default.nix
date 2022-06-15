{ lib, linuxKernel, linuxPackagesFor, writeText, buildPackages, fetchurl, fetchFromGitHub, raspberrypifw, ... }: rec {
  kernel = linuxKernel.kernels.linux_rpi4.override {
    argsOverride = rec {
      modDirVersion = "5.15.43-rt45";
      version = "${modDirVersion}-notag";
      src = fetchFromGitHub {
        owner = "raspberrypi";
        repo = "linux";
        rev = "97be5486aeff2253079e75fc3222fbe66118cf12";
        sha256 = "7D4B68n3diMYU/1ugQ/8nESR5dRIsYfmGSNmbq3rKkM=";
      };
      kernelPatches = [{
        name = "rt";
        patch = fetchurl {
          url = "https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.15/older/patch-5.15.43-rt45.patch.xz";
          sha256 = "veAJl5zb5SEYQoGzoZtURFncHD42hQ8cX7zeS36CQvk=";
        };
      }] ++ linuxKernel.kernels.linux_rpi4.kernelPatches;
      structuredExtraConfig = with lib.kernel; {
        KVM = lib.mkForce no; # Not compatible with PREEMPT_RT. NOTE: this conflict shoulb be fixed in 5.16
        PREEMPT_RT = yes;
        EXPERT = yes; # PREEMPT_RT depends on it (in kernel/Kconfig.preempt)
        PREEMPT_VOLUNTARY = lib.mkForce no; # PREEMPT_RT deselects it.
        RT_GROUP_SCHED = lib.mkForce (option no); # Removed by sched-disable-rt-group-sched-on-rt.patch.
      } // linuxKernel.kernels.linux_rpi4.structuredExtraConfig;
    };
  };

  linuxPackages = (linuxPackagesFor kernel);

  firmware = raspberrypifw.overrideAttrs (old: rec {
    version = "notag";
    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "firmware";
      rev = "f145afcfdc76157622588d5c58b95da24acea1e8";
      sha256 = "dvUl3su9brcZ9Xamr/0UJWXuJG1FyDFPS5x5tYcJkl8=";
    };
  });
}
