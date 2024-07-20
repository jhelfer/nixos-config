{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  persistDir = "/persist";
in
{
  extra = {
    inherit persistDir;
    luksDevice = "crypted";
    pkiBundle = "/etc/secureboot";
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./disks.nix
    ../../modules/secure-boot.nix
    ../../modules/persistence.nix
    ../../users/johe.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usbhid"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "WS1061";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Berlin";

  i18n.extraLocaleSettings = {
    LC_COLLATE = "C.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;

  fonts.enableDefaultPackages = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  hardware.enableAllFirmware = true;

  system.stateVersion = "24.11";
}
