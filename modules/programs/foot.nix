{ config, ... }:
{
  home-manager.users."${config.extra.username}" = {
    programs.foot = {
      enable = true;
      settings = {
        main.font = "monospace:size=10";
        scrollback.lines = 10000;
      };
    };
  };
}
