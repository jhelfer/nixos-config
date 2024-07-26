{ hmConfig, pkgs }:
{
  home-manager.users."${hmConfig.username}" = {
    home = {
      packages = [ pkgs.zed-editor ];
      sessionVariables.EDITOR = "zed";
      persistence."${hmConfig.persistDir}".directories = [ ".local/share/zed" ];
    };

    xdg.configFile."zed/settings.json".text = ''
      {
        "soft_wrap": "none",
        "tab_size": 2
      }
    '';
  };
}
