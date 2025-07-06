# system-settings.nix
#
# Configures basic system-wide settings such as time,
# internationalization (i18n), and console behavior.
{ config, pkgs, specialArgs, ... }: # Added hostname to arguments
{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 524288000;
    http-connections = 100;
    max-jobs = "auto";
  };

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";

  # Set the system's hostname using the value passed from flake.nix
  networking.hostName = specialArgs.hostname; # Use the passed hostname argument
  networking.networkmanager.enable = true;
  
  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  programs.zsh.enable = true;  

  networking.firewall.enable = false;

  services.gvfs.enable = true;

  # services.flatpak.enable = true;

}
