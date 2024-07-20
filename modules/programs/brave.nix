{ config, ... }:
{
  home-manager.users."${config.extra.username}" = {
    programs.brave.enable = true;
    home.persistence."${config.extra.homePersistDir}".directories = [
      ".config/BraveSoftware/Brave-Browser"
    ];
  };
}
