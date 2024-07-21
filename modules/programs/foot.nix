{ hmConfig }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.foot = {
      enable = true;
      settings = {
        main.font = "monospace:size=10";
        scrollback.lines = 10000;
      };
    };
  };
}
