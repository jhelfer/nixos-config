{ hmConfig }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.brave.enable = true;
    home.persistence."${hmConfig.persistDir}".directories = [ ".config/BraveSoftware/Brave-Browser" ];
  };
}
