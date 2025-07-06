# boot.nix
#
# Configures the system bootloader (systemd-boot).
{ pkgs, lib, config, ... }: 
{
  # Enable systemd-boot as the primary bootloader
  boot.loader.systemd-boot.enable = true;

  # Allow NixOS to modify EFI variables for bootloader installation/updates
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  
  # Optional: Keep a few generations for easy rollback
  # This makes more sense in your main configuration.nix or a generic module,
  # but it's good practice for systemd-boot which puts kernels on ESP.
  # boot.cleanTmpDir = true; # Ensures temporary files are cleaned up
  # boot.loader.systemd-boot.configurationLimit = 10; # Limit generations to keep
}
