{ config, ... }:
{
  home-manager.users."${config.extra.username}" = {
    programs.zoxide.enable = true;
    home.persistence."${config.extra.homePersistDir}".directories = [
      ".local/share/zoxide"
    ];
  };
}
