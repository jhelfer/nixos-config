{
  config,
  inputs,
  pkgs,
  ...
}:
let
  homeDirectory = "/home/${username}";
  homePersistDir = "${config.extra.persistDir}${homeDirectory}";
  username = "johe";
in
{
  extra = {
    homeManager = config.home-manager.users."${username}";
    inherit homePersistDir;
    inherit username;
  };

  imports = [
    ../modules/programs/brave.nix
    ../modules/programs/foot.nix
    ../modules/programs/git.nix
    ../modules/programs/niri.nix
    ../modules/programs/zed-editor.nix
    ../modules/programs/zoxide.nix
    ../modules/programs/zsh.nix
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPasswordFile = "${config.extra.persistDir}/passwords/${username}";
    packages = [ pkgs.xdg-utils ];
  };

  home-manager.users."${username}" = {
    imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

    programs.fzf.enable = true;

    home = {
      inherit username;
      inherit homeDirectory;

      persistence."${homePersistDir}" = {
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
