hostname: { inputs, pkgs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/audio.nix
    ../../modules/boot.nix
    ../../modules/ephemeral
    ../../modules/wifi.nix
    ./disk.nix
    ./users/johe
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.enableRedistributableFirmware = true;

  networking.hostName = hostname;

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  ephemeral = {
    enable = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/shadow"
    ];
  };

  system.stateVersion = "26.11";
}
