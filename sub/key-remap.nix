# key-remap.nix
{ config, pkgs, specialArgs, ... }: 

{
  boot.kernelModules = [ "hid_apple" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
  services.keyd.enable = true;
  services.keyd.keyboards = {
    default = {
      ids = [ "*" ];
      settings.main = { capslock = "leftcontrol"; };
    };
    "Magic Keyboard" = {
      ids = [ "004c:029c" ];
      settings.main = {
        capslock = "leftcontrol";
        rightmeta = "S-f1";
        fn = "S-f2";
        leftmeta = "S-f13";
      };
    };
  };
}
