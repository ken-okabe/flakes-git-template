# gnome-desktop.nix
{ config, pkgs, specialArgs, ... }:
{
  # Enable the Xorg server
  services.xserver.enable = true;

  # Enable the GNOME Display Manager (GDM)
  services.xserver.displayManager.gdm.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.desktopManager.gnome.enable = true;

  # Configure OpenGL drivers
  hardware.graphics.enable = true;

  # Enable XWayland
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    dconf-editor
    gnome-extension-manager
  ];
}
