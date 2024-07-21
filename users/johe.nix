{
  config,
  extraLib,
  inputs,
  osConfig,
  pkgs,
}:
let
  username = "johe";
  homeDirectory = "/home/${username}";
  persistDir = "${osConfig.persistDir}${homeDirectory}";
  callPackage = extraLib.callPackageWith {
    inherit pkgs;
    hmConfig = {
      inherit username;
      inherit homeDirectory;
      inherit persistDir;
      lib = config.home-manager.users."${username}".lib;
    };
  };
in
{
  imports = [
    (callPackage ../modules/programs/brave.nix)
    (callPackage ../modules/programs/foot.nix)
    (callPackage ../modules/programs/git.nix)
    (callPackage ../modules/programs/niri.nix)
    (callPackage ../modules/programs/zed-editor.nix)
    (callPackage ../modules/programs/zoxide.nix)
    (callPackage ../modules/programs/zsh.nix)
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPasswordFile = "${persistDir}/passwords/${username}";
    packages = [ pkgs.xdg-utils ];
  };

  home-manager.users."${username}" = {
    imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

    programs.fzf.enable = true;

    home = {
      inherit username;
      inherit homeDirectory;

      persistence."${persistDir}" = {
        directories = [
          ".local/state/wireplumber"
          "nixos-config"
        ];
        allowOther = true;
      };

      stateVersion = "24.11";
    };
  };
}
