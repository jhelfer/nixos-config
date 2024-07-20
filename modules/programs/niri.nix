{
  inputs,
  pkgs,
  config,
  ...
}:
let
  package = pkgs.niri-unstable;
in
{
  home-manager.users.${config.extra.username} = {
    imports = [ inputs.niri.homeModules.niri ];

    programs.niri = {
      enable = true;
      inherit package;
      settings = {
        binds = with config.extra.homeManager.lib.niri.actions; {
          "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
          "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
          "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
          "Mod+WheelScrollUp".action = focus-workspace-up;
          "Mod+WheelScrollDown".action = focus-workspace-down;
          "Mod+WheelScrollLeft" = {
            action = focus-column-left;
            cooldown-ms = 200;
          };
          "Mod+WheelScrollRight" = {
            action = focus-column-right;
            cooldown-ms = 200;
          };
          "Mod+Shift+S".action = screenshot;
          "Mod+F".action = maximize-column;
          "Mod+Q".action = close-window;
          "Mod+B".action = spawn "brave";
          "Mod+E".action = spawn "zed";
          "Mod+T".action = spawn "foot";
        };

        input = {
          keyboard.xkb.layout = "de";
          mouse = {
            natural-scroll = true;
          };
        };

        layout.default-column-width.proportion = 0.5;

        window-rules = [
          {
            geometry-corner-radius =
              let
                radius = 4.0;
              in
              {
                bottom-left = radius;
                bottom-right = radius;
                top-left = radius;
                top-right = radius;
              };
            clip-to-geometry = true;
          }
        ];

        prefer-no-csd = true;
      };
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ package ];
  };

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  hardware.graphics.enable = true;
}
