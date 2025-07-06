# system-packages.nix
#
# Defines essential system-wide packages that should be available to all users.
# More specialized applications or user-specific tools are often managed
# via other dedicated modules or Home Manager.
{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    # Core utilities
    git       # Version control system (also configured per-user via Home Manager)
    openssl

    gparted
  
    # Utilities
    webp-pixbuf-loader # For WebP image support in GTK/GNOME applications
    tree               # Displays directory structures as a tree
    bottom             # A graphical process/system monitor
    curl
    wget
    # htop
    # file
    which
    unzip

    baobab
    # man-pages # For offline man pages
    # man-db    # For `man` command itself and `mandb`
  
    # Web Browsers
    brave           # Privacy-focused web browser
    google-chrome   # Google Chrome (requires allowUnfree = true)
    chromium        # Open-source base for Chrome

    # Development Tools
    vscode          # Visual Studio Code (requires allowUnfree = true if using Microsoft's build)
                    # Alternatively, consider 'vscodium' for a fully FOSS build.
    # Graphics and Media
    gimp            # GNU Image Manipulation Program
    losslesscut-bin # Tool for lossless trimming/cutting of video and audio files
    mcomix          # Comic book reader

    # File Sharing
    transmission_4-gtk # BitTorrent client with a GTK interface

    dotnet-sdk
    nodejs_24
  ];
}
