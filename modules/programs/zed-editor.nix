{ pkgs, config, ... }:
{
  home-manager.users."${config.extra.username}" = {
    home = {
      packages = [ pkgs.zed-editor ];
      persistence."${config.extra.homePersistDir}".directories = [ ".local/share/zed" ];
    };

    xdg.configFile."zed/settings.json".text = ''
      {
        "soft_wrap": "none",
        "tab_size": 2
      }
    '';
  };
}
