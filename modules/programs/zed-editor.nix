{ hmConfig, pkgs }:
let
  jsonFormat = pkgs.formats.json { };
in
{
  home-manager.users."${hmConfig.username}" = {
    home = {
      packages = [ pkgs.zed-editor ];
      sessionVariables.EDITOR = "zed";
      persistence."${hmConfig.persistDir}".directories = [ ".local/share/zed" ];
    };

    xdg.configFile."zed/settings.json".source = jsonFormat.generate "zed-user-settings" {
      "auto_update" = false;
      "soft_wrap" = "none";
      "tab_size" = 2;
      "theme" = "One Dark";
    };
  };
}
