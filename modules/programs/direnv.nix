{ hmConfig }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.direnv.enable = true;
    home.persistence."${hmConfig.persistDir}".directories = [ ".local/share/direnv" ];
  };
}
