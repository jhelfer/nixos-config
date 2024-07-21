{ hmConfig }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.zoxide.enable = true;
    home.persistence."${hmConfig.persistDir}".directories = [ ".local/share/zoxide" ];
  };
}
