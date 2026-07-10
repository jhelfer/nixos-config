username: { inputs, ... }: {
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  home-manager.users.${username} = {
    programs.niri.settings = {
      prefer-no-csd = true;

      input = {
        keyboard.xkb.layout = "de";
        mouse.natural-scroll = true;
      };

      binds = {
        "Mod+F".action.maximize-column = { };
        "Mod+Q".action.close-window = { };

        "Mod+Down".action.focus-window-down = { };
        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };
        "Mod+Up".action.focus-window-up = { };

        "Mod+B".action.spawn = "zen-beta";
        "Mod+E".action.spawn = "zeditor";
        "Mod+T".action.spawn = "foot";
      };

      layout.default-column-width.proportion = 0.5;
    };
  };
}
